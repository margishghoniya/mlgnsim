import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/ChartJS';
import CHARTJS_ALT from '@salesforce/resourceUrl/ChartJS';

// ============================================================
// Module-level constants — plain JS values, never Proxied.
// ============================================================

const COLORS = [
	'#0176D3',
	'#2E844A',
	'#BA0517',
	'#FFB75D',
	'#9050E9',
	'#06A59A',
	'#F88962',
	'#5C6BC0',
	'#8BC34A',
	'#EC407A'
];

let chartJsLoadPromise = null;

/**
 * Resolves the Chart constructor function across different environment wrappers
 * (Salesforce Locker Service, LWS, UMD default exports, etc.)
 */
function getChartConstructor() {
	if (typeof window.Chart === 'function') {
		return window.Chart;
	}
	if (window.Chart && typeof window.Chart.Chart === 'function') {
		return window.Chart.Chart;
	}
	if (window.Chart && typeof window.Chart.default === 'function') {
		return window.Chart.default;
	}
	if (typeof Chart === 'function') {
		return Chart;
	}
	return null;
}

/**
 * Robust loader that handles both single-file and zip static resources (chartjs vs ChartJS).
 */
function loadChartLibrary(component) {
	if (getChartConstructor()) {
		return Promise.resolve();
	}

	if (chartJsLoadPromise) {
		return chartJsLoadPromise;
	}

	chartJsLoadPromise = loadScript(component, CHARTJS)
		.then(() => {
			if (getChartConstructor()) return;
			return loadScript(component, CHARTJS + '/chart.umd.min.js');
		})
		.then(() => {
			if (getChartConstructor()) return;
			return loadScript(component, CHARTJS + '/chart.min.js');
		})
		.then(() => {
			if (getChartConstructor()) return;
			return loadScript(component, CHARTJS_ALT);
		})
		.then(() => {
			if (getChartConstructor()) return;
			return loadScript(component, CHARTJS_ALT + '/chart.umd.min.js');
		})
		.catch((err) => {
			console.warn('ChartJS load notice:', err);
		});

	return chartJsLoadPromise;
}

export default class ChartRenderer extends LightningElement {

	_widget;

	@api
	get widget() {
		return this._widget;
	}
	set widget(value) {
		this._widget = value;
		if (this.chartJsInitialized) {
			Promise.resolve().then(() => {
				this.renderChart();
			});
		}
	}

	get widgetTitle() {
		return this._widget ? this._widget.title : 'Chart';
	}

	chart;
	chartJsInitialized = false;

	renderedCallback() {
		if (this.chartJsInitialized) {
			return;
		}

		if (getChartConstructor()) {
			this.chartJsInitialized = true;
			this.renderChart();
			return;
		}

		this.chartJsInitialized = true;

		loadChartLibrary(this)
			.then(() => {
				const ChartConstructor = getChartConstructor();
				if (ChartConstructor) {
					console.log('Chart.js loaded successfully');
					this.renderChart();
				} else {
					console.error('Chart.js script loaded but constructor could not be resolved');
				}
			})
			.catch(error => {
				if (getChartConstructor()) {
					this.renderChart();
				} else {
					console.error('ChartJS Load Error', error);
				}
			});
	}

	disconnectedCallback() {
		this.destroyChart();
	}

	renderChart() {
		if (!this._widget) {
			return;
		}

		const container = this.template.querySelector('.chartContainer');
		if (!container) {
			return;
		}

		try {
			this.destroyChart();

			container.innerHTML = '';

			const canvas = document.createElement('canvas');
			canvas.style.width = '100%';
			canvas.style.height = '100%';
			container.appendChild(canvas);

			const ctx = canvas.getContext('2d');

			// Deep clone widget to unwrap Proxy objects
			const plainWidget = JSON.parse(JSON.stringify(this._widget));
			const config = this.buildChartConfig(plainWidget);

			const ChartConstructor = getChartConstructor();
			if (ChartConstructor) {
				this.chart = new ChartConstructor(ctx, config);
			} else {
				console.warn('Chart.js constructor not available');
			}
		} catch (err) {
			console.error('Error rendering chart:', err.message || err);
		}
	}

	destroyChart() {
		if (this.chart) {
			this.chart.destroy();
			this.chart = null;
		}
	}

	refresh() {
		this.destroyChart();
		this.renderChart();
	}

	@api
	redraw(widget) {
		this.widget = widget;
		if (this.chartJsInitialized) {
			this.refresh();
		}
	}

	buildChartConfig(widget) {
		if (!widget) {
			return {};
		}

		const chartType = (widget.chartType || 'bar').toLowerCase();
		const labels = widget.labels || [];
		const datasets = [];

		const rawSeries = widget.series || widget.datasets || [];

		if (Array.isArray(rawSeries)) {
			rawSeries.forEach((s, i) => {
				datasets.push({
					label: s.name || s.label || `Series ${i + 1}`,
					data: s.data || [],
					borderWidth: s.borderWidth || 2,
					borderColor: s.borderColor || COLORS[i % COLORS.length],
					backgroundColor: s.backgroundColor || COLORS[i % COLORS.length],
					fill: s.fill || false,
					tension: 0.4
				});
			});
		}

		const commonOptions = {
			responsive: true,
			maintainAspectRatio: false,
			animation: { duration: 1000 },
			plugins: {
				legend: { display: true, position: 'bottom' },
				tooltip: { enabled: true }
			}
		};

		switch (chartType) {

			case 'line':
				return {
					type: 'line',
					data: { labels, datasets },
					options: {
						...commonOptions,
						scales: { y: { beginAtZero: true } }
					}
				};

			case 'bar':
				datasets.forEach(ds => {
					ds.backgroundColor = [...COLORS];
					ds.borderColor = [...COLORS];
				});
				return {
					type: 'bar',
					data: { labels, datasets },
					options: {
						...commonOptions,
						scales: { y: { beginAtZero: true } }
					}
				};

			case 'pie':
				datasets.forEach(ds => {
					ds.backgroundColor = [...COLORS];
					ds.borderColor = '#ffffff';
					ds.borderWidth = 2;
				});
				return {
					type: 'pie',
					data: { labels, datasets },
					options: {
						...commonOptions,
						plugins: { legend: { display: true, position: 'right' } }
					}
				};

			case 'doughnut':
				datasets.forEach(ds => {
					ds.backgroundColor = [...COLORS];
					ds.borderColor = '#ffffff';
					ds.borderWidth = 2;
				});
				return {
					type: 'doughnut',
					data: { labels, datasets },
					options: {
						...commonOptions,
						cutout: '60%',
						plugins: { legend: { display: true, position: 'right' } }
					}
				};

			case 'radar':
				datasets.forEach((ds, i) => {
					ds.backgroundColor = COLORS[i % COLORS.length] + '55';
					ds.borderColor = COLORS[i % COLORS.length];
					ds.pointBackgroundColor = COLORS[i % COLORS.length];
					ds.pointRadius = 5;
				});
				return {
					type: 'radar',
					data: { labels, datasets },
					options: {
						...commonOptions,
						scales: { r: { beginAtZero: true, suggestedMax: 100 } }
					}
				};

			case 'polararea':
				datasets.forEach(ds => {
					ds.backgroundColor = [...COLORS];
				});
				return {
					type: 'polarArea',
					data: { labels, datasets },
					options: { ...commonOptions }
				};

			case 'scatter':
				return {
					type: 'scatter',
					data: { datasets },
					options: {
						...commonOptions,
						scales: {
							x: { type: 'linear', position: 'bottom' },
							y: { beginAtZero: true }
						}
					}
				};

			case 'bubble':
				return {
					type: 'bubble',
					data: { datasets },
					options: { ...commonOptions }
				};

			default:
				return {
					type: 'bar',
					data: { labels, datasets },
					options: commonOptions
				};
		}
	}
}