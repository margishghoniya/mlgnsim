public without sharing class ClaudeConfig {

    /* Named Credential
     */
    public static final String NAMED_CREDENTIAL = 'callout:ClaudeAI';

    /* Claude Messages Endpoint
     */
    public static final String MESSAGE_ENDPOINT = NAMED_CREDENTIAL + '/v1/messages';

    /* Claude Model
     */
    public static final String MODEL = 'claude-sonnet-5';

    /* Claude API Version
     */
    public static final String API_VERSION = '2023-06-01';

    /* Maximum Tokens
     */
    public static final Integer MAX_TOKENS = 4000;

    /* Temperature
     */
   // public static final Decimal TEMPERATURE = 0.2;

    /*Timeout (Milliseconds)
     */
    public static final Integer TIMEOUT = 120000;

    /* Content Type
     */
    public static final String CONTENT_TYPE ='application/json';

    /* Default System Prompt
     */
    public static final String SYSTEM_PROMPT = 'You are an enterprise Salesforce AI assistant. ' + 'Always return structured JSON only. ' + 'Do not return markdown.';

    /* Dashboard Prompt Prefix
     */
    public static final String DASHBOARD_PROMPT = 'Analyze the supplied data and return ' + 'dashboard information including KPIs, ' + 'charts, risk score, recommendations, '+ 'and executive summary in JSON format.';

    /*
     * Logging Enabled
     */
    public static final Boolean ENABLE_LOGGING = true;

    /*
     * Debug Enabled
     */
    public static final Boolean DEBUG = true;

}