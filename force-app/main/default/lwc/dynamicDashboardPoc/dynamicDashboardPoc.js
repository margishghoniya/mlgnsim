import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/ChartJS';
import parseDashboardJson from '@salesforce/apex/DashboardCardController.parseDashboardJson';

const DEFAULT_BG = '#93c5fd';
const DEFAULT_BORDER = '#60a5fa';

export default class DynamicDashboard extends LightningElement {
	jsonInput = '';
	cards = [];
	errorMessage;
	isLoading = false;

	chartJsPromise;
	chartInstances = {}; // domId -> Chart.js instance

	connectedCallback() {
		this.chartJsPromise = loadScript(this, CHARTJS).catch((error) => {
			this.errorMessage = 'Failed to load the charting library: ' + this.extractErrorMessage(error);
		});
	}

	disconnectedCallback() {
		this.destroyAllCharts();
	}

	// ---------------------------------------------------------------
	// Input handling
	// ---------------------------------------------------------------

	handleJsonInputChange(event) {
		this.jsonInput = event.target.value;
	}

	handleGenerate() {
		this.errorMessage = undefined;
		this.isLoading = true;

		parseDashboardJson({ jsonInput: this.jsonInput })
			.then((response) => {
				this.cards = response.cards || [];
				return this.chartJsPromise;
			})
			.then(() => this.renderCharts())
			.catch((error) => {
				this.cards = [];
				this.errorMessage = this.extractErrorMessage(error);
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	// ---------------------------------------------------------------
	// Rendering - cards already arrive normalized from Apex
	// (key, isKpi, isChart, domId, chartType, labels, datasets,
	//  isTable, columnHeaders, rows, isUnsupported, unsupportedMessage)
	// ---------------------------------------------------------------

	renderCharts() {
		if (!window.Chart) {
			return;
		}
		this.destroyAllCharts();

		this.cards
			.filter((c) => c.isChart)
			.forEach((card) => {
				const canvas = this.template.querySelector(`[data-id="${card.domId}"]`);
				if (!canvas) {
					return;
				}
				const datasets = (card.datasets || []).map((ds) => ({
					backgroundColor: DEFAULT_BG,
					borderColor: DEFAULT_BORDER,
					borderWidth: card.chartType === 'line' ? 2 : 1,
					borderRadius: card.chartType === 'bar' ? 4 : 0,
					label: ds.label,
					data: ds.data
				}));
				this.chartInstances[card.domId] = new window.Chart(canvas.getContext('2d'), {
					type: card.chartType,
					data: { labels: card.labels || [], datasets },
					options: {
						responsive: true,
						maintainAspectRatio: false,
						plugins: { legend: { display: true, position: 'top', align: 'start' } }
					}
				});
			});
	}

	destroyAllCharts() {
		Object.values(this.chartInstances).forEach((chart) => chart.destroy());
		this.chartInstances = {};
	}

	// ---------------------------------------------------------------
	// Helpers
	// ---------------------------------------------------------------

	extractErrorMessage(error) {
		if (error?.body?.message) {
			return error.body.message;
		}
		if (error?.message) {
			return error.message;
		}
		return 'Something went wrong.';
	}

	get hasCards() {
		return this.cards.length > 0;
	}

	get hasError() {
		return !!this.errorMessage;
	}
}