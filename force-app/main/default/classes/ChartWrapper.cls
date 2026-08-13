public without sharing class ChartWrapper {

    /**
     * Chart title
     */
    @AuraEnabled public String title;

    /**
     * Chart type
     * bar
     * line
     * pie
     * doughnut
     * radar
     */
    @AuraEnabled public String chartType;

    /**
     * X-Axis Labels
     */
    @AuraEnabled public List<String> labels;

    /**
     * Dataset Collection
     */
    @AuraEnabled public List<DataSet> datasets;

    /**
     * Constructor
     */
    public ChartWrapper() {
        labels = new List<String>();
        datasets = new List<DataSet>();
    }

    /**
     * Dataset Wrapper
     */
    public class DataSet {

        /**
         * Dataset Name
         */
        @AuraEnabled public String label;

        /**
         * Values
         */
        @AuraEnabled public List<Decimal> data;

        /**
         * Background Colors
         */
        @AuraEnabled public List<String> backgroundColor;

        /**
         * Border Colors
         */
        @AuraEnabled public List<String> borderColor;

        /**
         * Border Width
         */
        @AuraEnabled public Integer borderWidth;

        /**
         * Fill (For Line Chart)
         */
        @AuraEnabled public Boolean fill;

        /**
         * Constructor
         */
        public DataSet() {

            data = new List<Decimal>();

            backgroundColor = new List<String>();

            borderColor = new List<String>();

            borderWidth = 1;

            fill = false;
        }

    }

}