/**
 * ==========================================================
 * Class Name    : ClaudePromptBuilder
 * Description   : Builds prompts for Claude AI
 * ==========================================================
 */
public without sharing class ClaudePromptBuilder {
    /*
     * Build Dashboard Prompt
     */
    public static String buildDashboardPrompt(String businessData) {

        String prompt = ClaudeConfig.SYSTEM_PROMPT + '\n\n';

        prompt += ClaudeConfig.DASHBOARD_PROMPT + '\n\n';

        prompt += getDashboardJsonSchema();

        prompt += '\n\nBusiness Data:\n';

        prompt += businessData;

        return prompt;
    }

    /*
     * Executive Summary Prompt
     */
    public static String buildExecutiveSummaryPrompt(String businessData){

        String prompt = ClaudeConfig.SYSTEM_PROMPT;

        prompt += '\n\nGenerate an executive summary for the following data.\n';

        prompt += businessData;

        return prompt;
    }

    /*
     * Risk Analysis Prompt
     */
    public static String buildRiskPrompt(String businessData){

        String prompt = ClaudeConfig.SYSTEM_PROMPT;

        prompt += '\n\nAnalyze the following data and identify all risks.';

        prompt += '\nInclude:';

        prompt += '\n1. Risk Score';

        prompt += '\n2. Risk Level';

        prompt += '\n3. Reason';

        prompt += '\n4. Recommendation';

        prompt += '\n\n';

        prompt += businessData;

        return prompt;
    }

    /*
     * KPI Prompt
     */
    public static String buildKpiPrompt(String businessData){

        String prompt = ClaudeConfig.SYSTEM_PROMPT;

        prompt += '\n\nCalculate important KPIs.';

        prompt += '\nReturn JSON only.';

        prompt += '\n\n';

        prompt += businessData;

        return prompt;
    }

    /*
     * Chart Prompt
     */
    public static String buildChartPrompt(String businessData){

        String prompt = ClaudeConfig.SYSTEM_PROMPT;

        prompt += '\n\nGenerate chart data.';

        prompt += '\nRecommend chart type.';

        prompt += '\nReturn labels and datasets only in JSON.';

        prompt += '\n\n';

        prompt += businessData;

        return prompt;
    }

    /*
     * Credit Decision Prompt
     */
    public static String buildCreditDecisionPrompt(String businessData){

        String prompt = ClaudeConfig.SYSTEM_PROMPT;

        prompt += '\n\nAct as an experienced credit underwriter.';

        prompt += '\nReturn:';

        prompt += '\nApproval';

        prompt += '\nConfidence Score';

        prompt += '\nReason';

        prompt += '\nRisk';

        prompt += '\nRecommendation';

        prompt += '\n\n';

        prompt += businessData;

        return prompt;
    }

    /*
     * Salesforce Record Analysis Prompt
     */
    public static String buildSalesforceRecordPrompt(String objectName,
                                                     String recordJson){

        String prompt = ClaudeConfig.SYSTEM_PROMPT;

        prompt += '\n\nAnalyze Salesforce ' + objectName + ' record.';

        prompt += '\nProvide insights.';

        prompt += '\nIdentify missing data.';

        prompt += '\nRecommend next action.';

        prompt += '\n\n';

        prompt += recordJson;

        return prompt;
    }

    /*
     * Generic Prompt
     */
    public static String buildGenericPrompt(String instruction,
                                            String data){

        String prompt = ClaudeConfig.SYSTEM_PROMPT;

        prompt += '\n\n';

        prompt += instruction;

        prompt += '\n\n';

        prompt += data;

        return prompt;
    }

    /*
     * Dashboard JSON Schema
     */
    private static String getDashboardJsonSchema(){

        return
        'Return ONLY valid JSON in the following format:\n' +

        '{\n' +

        '"dashboardTitle":"",\n' +

        '"dashboardDescription":"",\n' +

        '"generatedBy":"Claude",\n' +

        '"executiveSummary":"",\n' +

        '"overallRisk":"",\n' +

        '"overallScore":0,\n' +

        '"aiRecommendation":"",\n' +

        '"totalRecords":0,\n' +

        '"approvedRecords":0,\n' +

        '"pendingRecords":0,\n' +

        '"rejectedRecords":0,\n' +

        '"warnings":[""],\n' +

        '"charts":[\n' +

        '{\n' +

        '"title":"",\n' +

        '"chartType":"bar",\n' +

        '"labels":[""],\n' +

        '"datasets":[\n' +

        '{\n' +

        '"label":"",\n' +

        '"data":[10,20,30]\n' +

        '}\n' +

        ']\n' +

        '}\n' +

        '],\n' +

        '"records":[\n' +

        '{\n' +

        '"recordId":"",\n' +

        '"recordName":"",\n' +

        '"category":"",\n' +

        '"status":"",\n' +

        '"score":0,\n' +

        '"recommendation":"",\n' +

        '"remarks":""\n' +

        '}\n' +

        ']\n' +

        '}';
    }

}