@IsTest
private class DashboardWrapperTest {

    @IsTest
    static void testDashboardWrapperConstructor() {

        Test.startTest();

        DashboardWrapper wrapper = new DashboardWrapper();

        Test.stopTest();

        // Verify constructor initialization
        System.assertNotEquals(null, wrapper.generatedOn, 'Generated On should be initialized');
        System.assertNotEquals(null, wrapper.charts, 'Charts list should be initialized');
        System.assertNotEquals(null, wrapper.records, 'Records list should be initialized');
        System.assertNotEquals(null, wrapper.warnings, 'Warnings list should be initialized');

        System.assertEquals(0, wrapper.charts.size());
        System.assertEquals(0, wrapper.records.size());
        System.assertEquals(0, wrapper.warnings.size());
    }

    @IsTest
    static void testDashboardRecord() {

        DashboardWrapper.DashboardRecord record = new DashboardWrapper.DashboardRecord();

        record.recordId = 'APP-1001';
        record.recordName = 'Michael Thompson';
        record.category = 'Business Loan';
        record.status = 'Approved';
        record.score = 92.5;
        record.recommendation = 'Approve';
        record.remarks = 'Excellent financial profile';

        System.assertEquals('APP-1001', record.recordId);
        System.assertEquals('Michael Thompson', record.recordName);
        System.assertEquals('Business Loan', record.category);
        System.assertEquals('Approved', record.status);
        System.assertEquals(92.5, record.score);
        System.assertEquals('Approve', record.recommendation);
        System.assertEquals('Excellent financial profile', record.remarks);
    }

    @IsTest
    static void testAddRecordsChartsWarnings() {

        DashboardWrapper wrapper = new DashboardWrapper();

        // Dashboard Details
        wrapper.dashboardTitle = 'Loan Risk Dashboard';
        wrapper.dashboardDescription = 'Claude AI Dashboard';
        wrapper.generatedBy = 'Claude AI';
        wrapper.executiveSummary = 'Applicant is financially stable.';
        wrapper.aiRecommendation = 'Approve';
        wrapper.overallRisk = 'Low';

        wrapper.totalRecords = 10;
        wrapper.approvedRecords = 8;
        wrapper.pendingRecords = 1;
        wrapper.rejectedRecords = 1;
        wrapper.overallScore = 91.25;

        // Add Dashboard Record
        DashboardWrapper.DashboardRecord rec = new DashboardWrapper.DashboardRecord();
        rec.recordId = '100';
        rec.recordName = 'John Doe';
        rec.status = 'Approved';
        rec.score = 91.25;
        wrapper.records.add(rec);

        // Add Warning
        wrapper.warnings.add('Low balance detected.');

        // Add Chart (requires ChartWrapper default constructor)
        ChartWrapper chart = new ChartWrapper();
        wrapper.charts.add(chart);

        // Assertions
        System.assertEquals('Loan Risk Dashboard', wrapper.dashboardTitle);
        System.assertEquals('Claude AI Dashboard', wrapper.dashboardDescription);
        System.assertEquals('Claude AI', wrapper.generatedBy);
        System.assertEquals('Applicant is financially stable.', wrapper.executiveSummary);
        System.assertEquals('Approve', wrapper.aiRecommendation);
        System.assertEquals('Low', wrapper.overallRisk);

        System.assertEquals(10, wrapper.totalRecords);
        System.assertEquals(8, wrapper.approvedRecords);
        System.assertEquals(1, wrapper.pendingRecords);
        System.assertEquals(1, wrapper.rejectedRecords);
        System.assertEquals(91.25, wrapper.overallScore);

        System.assertEquals(1, wrapper.records.size());
        System.assertEquals(1, wrapper.warnings.size());
        System.assertEquals(1, wrapper.charts.size());
    }
}