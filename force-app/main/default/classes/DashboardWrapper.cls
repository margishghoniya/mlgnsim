public without sharing class DashboardWrapper {

    /*Dashboard Information
     */
    @AuraEnabled public String dashboardTitle;
    @AuraEnabled public String dashboardDescription;
    @AuraEnabled public String generatedBy;
    @AuraEnabled public Datetime generatedOn;

    /*AI Summary
     */
    @AuraEnabled public String executiveSummary;
    @AuraEnabled public String aiRecommendation;
    @AuraEnabled public String overallRisk;

    /*KPI Cards
     */
    @AuraEnabled public Integer totalRecords;
    @AuraEnabled public Integer approvedRecords;
    @AuraEnabled public Integer pendingRecords;
    @AuraEnabled public Integer rejectedRecords;

    /* Overall Score
     */
    @AuraEnabled public Decimal overallScore;

    /* Charts
     */
    @AuraEnabled public List<ChartWrapper> charts;

    /* Detailed Records
     */
    @AuraEnabled public List<DashboardRecord> records;

    /* Warnings
     */
    @AuraEnabled public List<String> warnings;

    /* Constructor
     */
    public DashboardWrapper() {

        generatedOn = Datetime.now();

        charts = new List<ChartWrapper>();

        records = new List<DashboardRecord>();

        warnings = new List<String>();
    }

    /* Dashboard Detail Record
     */
    public class DashboardRecord {

        @AuraEnabled public String recordId;
        @AuraEnabled public String recordName;
        @AuraEnabled public String category;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal score;
        @AuraEnabled public String recommendation;
        @AuraEnabled public String remarks;

    }
}