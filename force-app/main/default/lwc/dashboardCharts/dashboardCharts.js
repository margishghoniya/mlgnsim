import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import ChartJS from '@salesforce/resourceUrl/ChartJS';

export default class DashboardCharts extends LightningElement {

    @api charts = [];

    chartJsInitialized = false;

    chartObjects = [];

    renderedCallback() {

        if (this.chartJsInitialized) {
            
            this.renderCharts();
            return;
        }

        this.chartJsInitialized = true;

        loadScript(this, ChartJS + '/chart.umd.min.js')
            .then(() => {

                console.log('ChartJS Loaded');
        console.log(window.Chart);

                this.renderCharts();

            })
            .catch(error => {

        console.error('ChartJS Load Error', error);

            });

    }

renderCharts() {

    console.log('========================');
    console.log('renderCharts called');
    console.log('Charts:', JSON.stringify(this.charts));
    console.log('ChartList:', JSON.stringify(this.chartList));

    if (!window.Chart) {
        console.log('Chart library NOT loaded');
        return;
    }

    console.log('Chart library loaded');

    this.chartObjects.forEach(c => c.destroy());
    this.chartObjects = [];

    for (const item of this.chartList) {

        console.log('Rendering:', item.title);

        const canvas = this.template.querySelector(
            `canvas[data-id="${item.id}"]`
        );

        console.log('Canvas:', canvas);

        if (!canvas) {
            console.log('Canvas NOT FOUND');
            return;
        }

        console.log('Labels:', item.labels);
        console.log('Datasets:', item.datasets);

        const ctx = canvas.getContext('2d');

        try {

    const chart = new window.Chart(ctx, {

        type: item.chartType,

        data: {

            labels: [...item.labels],

            datasets: JSON.parse(JSON.stringify(item.datasets))

        },

        options: {

            responsive: true,

            maintainAspectRatio: false

        }

    });

    console.log('Chart created successfully');

    this.chartObjects.push(chart);

}
catch (e) {

    console.error('Chart Error');

    console.error(e);

    console.error(e.message);

    console.error(e.stack);

}

}

}

    get chartList() {

        return (this.charts || []).map((chart, index) => {

            return {

                ...chart,

                id: 'chart' + index

            };

        });

    }

    get hasCharts() {

        return this.chartList.length > 0;

    }

}