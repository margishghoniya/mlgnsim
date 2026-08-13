import { LightningElement, api } from 'lwc';

const COLUMNS = [

    {
        label: 'Record Name',
        fieldName: 'recordName',
        type: 'text'
    },

    {
        label: 'Category',
        fieldName: 'category',
        type: 'text'
    },

    {
        label: 'Status',
        fieldName: 'status',
        type: 'text'
    },

    {
        label: 'Score',
        fieldName: 'score',
        type: 'number',
        cellAttributes: {
            alignment: 'center'
        }
    },

    {
        label: 'Recommendation',
        fieldName: 'recommendation',
        type: 'text'
    },

    {
        label: 'Remarks',
        fieldName: 'remarks',
        type: 'text'
    }

];

export default class DashboardTable extends LightningElement {

    @api records = [];

    columns = COLUMNS;

    get hasRecords() {

        return this.records && this.records.length > 0;

    }

}