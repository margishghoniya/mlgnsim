import { LightningElement, track } from 'lwc';

// Apex Method
import parseDashboard from '@salesforce/apex/dashboardCtrl_MG.parseDashboard';

export default class AiDashboard extends LightningElement {

	/*==============================================================
		JSON entered by user
	==============================================================*/
	@track jsonInput = '';

	/*==============================================================
		Complete Dashboard returned by Apex
	==============================================================*/
	@track dashboard;

	/*==============================================================
		Spinner
	==============================================================*/
	@track isLoading = false;

	/*==============================================================
		Error Message
	==============================================================*/
	@track errorMessage;

	/*==============================================================
		Called whenever user types/pastes JSON
	==============================================================*/
	handleJsonChange(event) {
		// alert('call handleJsonChange===');
		this.jsonInput = event.target.value;

	}

	/*==============================================================
		Generate Dashboard Button Click
	==============================================================*/
	generateDashboard() {
		// alert('this.jsonInput===' + this.jsonInput);
		// Clear previous error
		this.errorMessage = null;

		// Check empty input
		if (!this.jsonInput) {

			this.errorMessage = 'Please paste JSON';

			return;
		}

		this.isLoading = true;

		// Call Apex

		parseDashboard({
			jsonText: this.jsonInput
		})

			.then(result => {

				console.log('Dashboard Result');
				console.log(result);

				/*
				 * Save complete response
				 */

				this.dashboard = result;

				/*
				 * Prepare Widgets
				 */

				this.prepareWidgets();

			})

			.catch(error => {

				console.error(error);

				this.errorMessage =
					error.body ?
						error.body.message :
						error.message;

			})

			.finally(() => {

				this.isLoading = false;

			});

	}

	/*==============================================================
		Prepare Widgets
		Purpose:
		Add helper properties which HTML can directly use.

		Instead of checking

		widget.type == 'chart'

		HTML simply uses

		widget.isChart
	==============================================================*/

	prepareWidgets() {

		if (!this.dashboard) {

			return;

		}

		this.dashboard.widgets.forEach(widget => {

			//--------------------------------------------------
			// KPI
			//--------------------------------------------------

			widget.isKPI =
				// widget.type === 'kpiGroup';
				widget.type === 'kpi';

			//--------------------------------------------------
			// Chart
			//--------------------------------------------------

			widget.isChart =
				widget.type === 'chart';

			//--------------------------------------------------
			// Table
			//--------------------------------------------------

			widget.isTable =
				widget.type === 'table';

			//--------------------------------------------------
			// Timeline
			//--------------------------------------------------

			widget.isTimeline =
				widget.type === 'timeline';

			//--------------------------------------------------
			// Progress
			//--------------------------------------------------

			widget.isProgress =
				widget.type === 'progress';

			//--------------------------------------------------
			// List
			//--------------------------------------------------

			widget.isList =
				widget.type === 'list';

		});

		/*
		 * Reassign object
		 * So LWC refreshes UI
		 */

		this.dashboard = {
			...this.dashboard
		};

	}

	/*==============================================================
		Show Dashboard

		HTML uses

		<template if:true={showDashboard}>
	==============================================================*/

	get showDashboard() {

		return this.dashboard != null;

	}

	/*==============================================================
		Show Error

		HTML uses

		<template if:true={showError}>
	==============================================================*/

	get showError() {

		return this.errorMessage != null;

	}

}