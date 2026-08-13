import { LightningElement, api } from 'lwc';
import getAIAnalysis from '@salesforce/apex/AIAnalysisController.getAIAnalysis';

const RISK_STYLE = {
	LOW: { badgeClass: 'risk-badge risk-low', barClass: 'risk-bar risk-bar-low' },
	MEDIUM: { badgeClass: 'risk-badge risk-medium', barClass: 'risk-bar risk-bar-medium' },
	HIGH: { badgeClass: 'risk-badge risk-high', barClass: 'risk-bar risk-bar-high' },
	PASSED: { badgeClass: 'risk-badge risk-passed', barClass: 'risk-bar risk-bar-passed' }
};

export default class DimensionAnalysisList extends LightningElement {
	@api recordId; // Case Id, auto-populated when placed on a Case record page

	isLoading = false;
	errorMessage;
	dimensions = [];
	expandedLabel;

	connectedCallback() {
		this.loadAnalysis();
	}

	/** Public so a parent (e.g. a "Refresh Analysis" header button) can trigger a re-fetch. */
	@api
	refresh() {
		this.loadAnalysis();
	}

	loadAnalysis() {
		if (!this.recordId) {
			this.errorMessage = 'No Case record found on this page.';
			return;
		}

		this.isLoading = true;
		this.errorMessage = undefined;

		getAIAnalysis({ caseId: this.recordId })
			.then((response) => {
				this.dimensions = (response.dimensions || []).map((d) => {
					const style = RISK_STYLE[d.riskLevel] || RISK_STYLE.LOW;
					return {
						...d,
						key: d.label,
						confidenceLabel: `${d.confidence}%`,
						badgeClass: style.badgeClass,
						barClass: style.barClass,
						barStyle: `width: ${d.confidence}%`,
						isExpanded: false
					};
				});
			})
			.catch((error) => {
				this.dimensions = [];
				this.errorMessage = this.extractErrorMessage(error);
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	handleRowToggle(event) {
		const label = event.currentTarget.dataset.label;
		this.dimensions = this.dimensions.map((d) =>
			d.key === label ? { ...d, isExpanded: !d.isExpanded } : d
		);
	}

	handleRetry() {
		this.loadAnalysis();
	}

	extractErrorMessage(error) {
		if (error?.body?.message) {
			return error.body.message;
		}
		if (error?.message) {
			return error.message;
		}
		return 'Something went wrong loading the AI analysis.';
	}

	get hasError() {
		return !!this.errorMessage;
	}

	get hasDimensions() {
		return !this.isLoading && !this.hasError && this.dimensions.length > 0;
	}

	get isEmpty() {
		return !this.isLoading && !this.hasError && this.dimensions.length === 0;
	}
}