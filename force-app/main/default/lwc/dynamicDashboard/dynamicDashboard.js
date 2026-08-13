import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/ChartJS';
import generateDashboardJson from '@salesforce/apex/DashboardAIController.generateDashboardJson';

const CHART_TYPES = ['bar', 'line', 'doughnut', 'pie', 'radar', 'polarArea'];

export default class DynamicDashboard extends LightningElement {
	@api recordId; // optional - Case Id when placed on a record page

	dashboardTitle = '';
	widgets = [];
	jsonInput = '';
	promptInput = 'Generate a multi-dimension risk analysis dashboard for this case.';
	isLoading = false;
	errorMessage;

	chartJsPromise;
	chartInstances = {}; // domId -> Chart.js instance, so re-render doesn't leak/collide

	connectedCallback() {
		this.chartJsPromise = loadScript(this, CHARTJS).catch((error) => {
			this.errorMessage = 'Failed to load the charting library: ' + this.extractErrorMessage(error);
		});
	}

	disconnectedCallback() {
		this.destroyAllCharts();
	}

	// ---------------------------------------------------------------
	// Input handlers
	// ---------------------------------------------------------------

	handleJsonInputChange(event) {
		this.jsonInput = event.target.value;
	}

	handlePromptChange(event) {
		this.promptInput = event.target.value;
	}

	/** Manual flow: user pastes a Claude-produced JSON response directly. */
	handleRenderFromPaste() {
		this.errorMessage = undefined;
		try {
			const parsed = JSON.parse(this.jsonInput);
			this.applyDashboardJson(parsed);
		} catch (e) {
			this.errorMessage = 'Invalid JSON: ' + e.message;
		}
	}

	/** Live flow: Apex calls Claude and returns the dashboard JSON directly. */
	handleGenerateFromClaude() {
		this.errorMessage = undefined;
		this.isLoading = true;

		generateDashboardJson({ caseId: this.recordId, userPrompt: this.promptInput })
			.then((jsonString) => {
				this.jsonInput = jsonString; // reflect into the textarea so it's visible/editable
				const parsed = JSON.parse(jsonString);
				this.applyDashboardJson(parsed);
			})
			.catch((error) => {
				this.errorMessage = this.extractErrorMessage(error);
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	// ---------------------------------------------------------------
	// Rendering
	// ---------------------------------------------------------------

	applyDashboardJson(parsed) {
		this.dashboardTitle = parsed.title || 'Dashboard';
		alert('JSON parsed successfully: ' + JSON.stringify(parsed));
		const rawWidgets = Array.isArray(parsed.widgets) ? parsed.widgets : [];
		this.widgets = rawWidgets.map((w, idx) => {
			const domId = `chart-${w.id || idx}`;
			const isKpi = w.type === 'kpi';
			const isValidType = isKpi || CHART_TYPES.includes(w.type);
			return {
				...w,
				domId,
				isKpi,
				isValidType,
				showChart: !isKpi && isValidType,
				unsupportedType: !isValidType ? `Unsupported chart type: "${w.type}"` : undefined
			};
		});

		// Canvases render on the next microtask; wait for the DOM,
		// then wait for Chart.js (in case it hasn't finished loading yet).
		Promise.resolve()
			.then(() => this.chartJsPromise)
			.then(() => this.renderCharts());
	}

	renderCharts() {
		if (!window.Chart) {
			return; // loadScript failed - errorMessage already set
		}

		this.destroyAllCharts();

		this.widgets
			.filter((w) => w.showChart)
			.forEach((widget) => {
				const canvas = this.template.querySelector(`[data-id="${widget.domId}"]`);
				if (!canvas) {
					return;
				}
				const ctx = canvas.getContext('2d');
				this.chartInstances[widget.domId] = new window.Chart(ctx, {
					type: widget.type,
					data: {
						labels: widget.labels || [],
						datasets: widget.datasets || []
					},
					options: widget.options || {
						responsive: true,
						maintainAspectRatio: false,
						plugins: { legend: { display: (widget.datasets || []).length > 1 } }
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

	get hasWidgets() {
		return this.widgets.length > 0;
	}

	get hasError() {
		return !!this.errorMessage;
	}
}