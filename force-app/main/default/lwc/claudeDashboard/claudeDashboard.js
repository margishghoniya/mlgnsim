import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateDashboard from '@salesforce/apex/ClaudeController.generateDashboard';

export default class ClaudeDashboard extends LightningElement {
	@track dashboard;
	@track isLoading = true;
	@track errorMessage = '';

	connectedCallback() {
		console.log('ClaudeDashboard connectedCallback');
		this.loadDashboard();
	}

	loadDashboard() {
		const payload = JSON.stringify({
			applicationId: 'APP-1001',
			loanAmount: 120000,
			creditScore: 740
		});

		this.isLoading = true;

		generateDashboard({ prompt: payload })
			.then(result => {
				console.log('Dashboard', result);
				this.dashboard = result;
			})
			.catch(error => {
				console.log(JSON.stringify(error));

				console.log(error.body);

				console.log(error.body?.message);
				this.errorMessage =
					error.body?.message || error.message;
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	handleGenerate(event) {
		console.log('Generate event received');
		console.log(event.detail);
		const prompt = event.detail.prompt;
		console.log('Prompt = ' + prompt);
		if (!prompt || prompt.trim() === '') {
			this.showToast(
				'Validation',
				'Please enter a prompt.',
				'warning'
			);
			return;
		}
		this.fetchDashboard(prompt);
	}

	async fetchDashboard(prompt) {
		console.log('Prompt:', prompt);
		this.isLoading = true;
		try {
			const result = await generateDashboard({
				prompt: prompt
			});

			this.dashboard = result;
			this.showToast(
				'Success',
				'Dashboard generated successfully.',
				'success'
			);
		}
		catch (error) {
			let message = 'Unknown Error';
			if (error.body) {
				if (Array.isArray(error.body)) {
					message = error.body.map(e => e.message).join(',');
				}
				else {
					message = error.body.message;
				}
			}

			this.showToast(
				'Error',
				message,
				'error'
			);
			console.error(error);
		}
		finally {
			this.isLoading = false;
		}
	}

	handleRetry() {
		const header = this.template.querySelector(
			'c-dashboard-header'
		);
		if (header) {
			this.fetchDashboard(header.prompt);
		}
	}

	showToast(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title,
				message,
				variant
			})
		);
	}
}