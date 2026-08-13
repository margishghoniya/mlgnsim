import { LightningElement, track } from 'lwc';

export default class DashboardHeader extends LightningElement {

    @track prompt = '';

    handlePromptChange(event) {
        this.prompt = event.target.value;
    }

    handleClear() {
        this.prompt = '';
    }

    handleGenerate() {

        if (!this.prompt || this.prompt.trim() === '') {
            return;
        }

        this.dispatchEvent(
            new CustomEvent('generate', {
                detail: {
                    prompt: this.prompt
                }
            })
        );
    }
}