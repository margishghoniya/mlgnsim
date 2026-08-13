import { LightningElement, api } from 'lwc';

export default class DashboardErrorPanel extends LightningElement {

    @api message = '';

    @api warnings = [];

    @api type = 'error';
    // error
    // warning
    // info
    // success

    @api showRetryButton = false;

    get showPanel() {
        return this.message || this.hasWarnings;
    }

    get hasWarnings() {
        return this.warnings && this.warnings.length > 0;
    }

    get panelTitle() {

        switch (this.type) {

            case 'warning':
                return 'Warning';

            case 'success':
                return 'Success';

            case 'info':
                return 'Information';

            default:
                return 'Error';
        }

    }

    get panelIcon() {

        switch (this.type) {

            case 'warning':
                return 'utility:warning';

            case 'success':
                return 'utility:success';

            case 'info':
                return 'utility:info';

            default:
                return 'utility:error';
        }

    }

    get containerClass() {

        switch (this.type) {

            case 'warning':
                return 'container warning';

            case 'success':
                return 'container success';

            case 'info':
                return 'container info';

            default:
                return 'container error';

        }

    }

    handleRetry() {

        this.dispatchEvent(

            new CustomEvent('retry')

        );

    }

}