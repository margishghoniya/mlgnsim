@IsTest
private class ClaudePromptBuilderTest {

    @IsTest
    static void testBuildDashboardPrompt() {

        String businessData = 'Revenue: 100000, Risk: Low';

        String prompt =
            ClaudePromptBuilder.buildDashboardPrompt(businessData);

        System.assertNotEquals(null, prompt);
        System.assert(prompt.contains(ClaudeConfig.SYSTEM_PROMPT));
        System.assert(prompt.contains(ClaudeConfig.DASHBOARD_PROMPT));
        System.assert(prompt.contains('Business Data:'));
        System.assert(prompt.contains(businessData));
        System.assert(prompt.contains('"dashboardTitle"'));
        System.assert(prompt.contains('"charts"'));
        System.assert(prompt.contains('"records"'));
    }

    @IsTest
    static void testBuildExecutiveSummaryPrompt() {

        String data = 'Annual Revenue: 500000';

        String prompt =
            ClaudePromptBuilder.buildExecutiveSummaryPrompt(data);

        System.assert(prompt.contains(ClaudeConfig.SYSTEM_PROMPT));
        System.assert(prompt.contains('Generate an executive summary'));
        System.assert(prompt.contains(data));
    }

    @IsTest
    static void testBuildRiskPrompt() {

        String data = 'Applicant Credit Score: 720';

        String prompt =
            ClaudePromptBuilder.buildRiskPrompt(data);

        System.assert(prompt.contains('Risk Score'));
        System.assert(prompt.contains('Risk Level'));
        System.assert(prompt.contains('Recommendation'));
        System.assert(prompt.contains(data));
    }

    @IsTest
    static void testBuildKpiPrompt() {

        String data = 'Monthly Sales';

        String prompt =
            ClaudePromptBuilder.buildKpiPrompt(data);

        System.assert(prompt.contains('Calculate important KPIs'));
        System.assert(prompt.contains('Return JSON only'));
        System.assert(prompt.contains(data));
    }

    @IsTest
    static void testBuildChartPrompt() {

        String data = 'Chart Data';

        String prompt =
            ClaudePromptBuilder.buildChartPrompt(data);

        System.assert(prompt.contains('Generate chart data'));
        System.assert(prompt.contains('Recommend chart type'));
        System.assert(prompt.contains('labels'));
        System.assert(prompt.contains(data));
    }

    @IsTest
    static void testBuildCreditDecisionPrompt() {

        String data = 'Loan Amount: 100000';

        String prompt =
            ClaudePromptBuilder.buildCreditDecisionPrompt(data);

        System.assert(prompt.contains('credit underwriter'));
        System.assert(prompt.contains('Approval'));
        System.assert(prompt.contains('Confidence Score'));
        System.assert(prompt.contains('Recommendation'));
        System.assert(prompt.contains(data));
    }

    @IsTest
    static void testBuildSalesforceRecordPrompt() {

        String objectName = 'Account';
        String json = '{"Name":"ABC Corp"}';

        String prompt =
            ClaudePromptBuilder.buildSalesforceRecordPrompt(
                objectName,
                json
            );

        System.assert(prompt.contains('Salesforce Account record'));
        System.assert(prompt.contains('Provide insights'));
        System.assert(prompt.contains('Identify missing data'));
        System.assert(prompt.contains('Recommend next action'));
        System.assert(prompt.contains(json));
    }

    @IsTest
    static void testBuildGenericPrompt() {

        String instruction = 'Summarize this data';
        String data = 'Sales increased by 15%.';

        String prompt =
            ClaudePromptBuilder.buildGenericPrompt(
                instruction,
                data
            );

        System.assert(prompt.contains(instruction));
        System.assert(prompt.contains(data));
        System.assert(prompt.contains(ClaudeConfig.SYSTEM_PROMPT));
    }

    @IsTest
    static void testEmptyInputs() {

        String prompt1 =
            ClaudePromptBuilder.buildDashboardPrompt('');

        System.assert(prompt1.contains('Business Data:'));

        String prompt2 =
            ClaudePromptBuilder.buildGenericPrompt('', '');

        System.assertNotEquals(null, prompt2);
    }

    @IsTest
    static void testNullInputs() {

        String prompt1 =
            ClaudePromptBuilder.buildDashboardPrompt(null);

        System.assertNotEquals(null, prompt1);

        String prompt2 =
            ClaudePromptBuilder.buildGenericPrompt(null, null);

        System.assertNotEquals(null, prompt2);
    }
}