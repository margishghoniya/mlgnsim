/**
 * DashboardAIController
 * -----------------------------------------------------------------
 * Calls Claude (Anthropic Messages API) via a Named Credential and
 * returns a JSON string describing a dashboard: a title plus a list
 * of widgets, each with a chart type and its own labels/datasets.
 * Nothing is persisted — this is a pure live pass-through, same as
 * the FastAPI agent pattern, just pointed at Claude instead.
 *
 * The LWC (dynamicDashboard) renders whatever widgets come back,
 * so the number of dimensions/charts is entirely driven by this
 * response — add a widget in the JSON, a chart appears, no LWC
 * changes needed.
 *
 * Setup required before use:
 *   1. Setup > Named Credentials > External Credentials > New
 *        - Auth Protocol: Custom
 *        - Add a Principal with a Custom Header parameter:
 *            Header name:  x-api-key
 *            Header value: <your Anthropic API key>
 *   2. Setup > Named Credentials > New Named Credential
 *        - Name: Claude_API
 *        - URL: https://api.anthropic.com
 *        - External Credential: (the one created above)
 */
public with sharing class DashboardAIController {

    private static final String NAMED_CREDENTIAL = 'callout:ClaudeAI';
    private static final String CLAUDE_MODEL = 'claude-sonnet-5'; // adjust to whatever model your account uses
    private static final Integer CALLOUT_TIMEOUT_MS = 60000;

    /**
     * Generates a dashboard JSON spec from Claude for the given Case
     * (optional) plus a free-text prompt describing what the
     * dashboard should show. Returns the raw JSON string, already
     * validated as parseable — the LWC parses it again client-side
     * to build the charts.
     */
    @AuraEnabled
    public static String generateDashboardJson(Id caseId, String userPrompt) {
        String caseContext = buildCaseContext(caseId);
        String fullPrompt = caseContext + (String.isNotBlank(userPrompt) ? userPrompt : 'Generate a risk analysis dashboard.');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + '/v1/messages');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('anthropic-version', '2023-06-01');
        req.setTimeout(CALLOUT_TIMEOUT_MS);

        Map<String, Object> body = new Map<String, Object>{
            'model' => CLAUDE_MODEL,
            'max_tokens' => 2000,
            'system' => buildSystemInstruction(),
            'messages' => new List<Map<String, Object>>{
                new Map<String, Object>{ 'role' => 'user', 'content' => fullPrompt }
            }
        };
        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (CalloutException ce) {
            throw new AuraHandledException('Could not reach Claude: ' + ce.getMessage());
        }

        if (res.getStatusCode() != 200) {
            throw new AuraHandledException(
                'Claude API returned an error (' + res.getStatusCode() + '): ' + res.getBody()
            );
        }
		system.debug('res.getBody()---'+res.getBody());
        return extractJsonFromClaudeResponse(res.getBody());
    }

    private static String buildCaseContext(Id caseId) {
        if (caseId == null) {
            return '';
        }
        List<Case> cases = [
            SELECT Id, CaseNumber, Account.Name, Status, Subject
            FROM Case
            WHERE Id = :caseId
            WITH USER_MODE
            LIMIT 1
        ];
        if (cases.isEmpty()) {
            return '';
        }
        Case c = cases[0];
        return 'Case ' + c.CaseNumber + ' for ' + (c.Account != null ? c.Account.Name : 'Unknown Account')
            + ', status ' + c.Status + '. ';
    }

    /**
     * The schema contract Claude must follow. Keep this in sync with
     * what dynamicDashboard.js expects when it maps widgets to charts.
     */
    @TestVisible
    private static String buildSystemInstruction() {
        return 'You are a dashboard configuration generator for a Salesforce Lightning Web Component. '
            + 'Respond with ONLY valid JSON — no markdown code fences, no commentary, no explanation. '
            + 'Match this exact schema:\n'
            + '{\n'
            + '  "title": string,\n'
            + '  "widgets": [\n'
            + '    {\n'
            + '      "id": string (unique, no spaces),\n'
            + '      "type": "bar" | "line" | "doughnut" | "pie" | "kpi",\n'
            + '      "title": string,\n'
            + '      "labels": [string],\n'
            + '      "datasets": [ { "label": string, "data": [number] } ],\n'
            + '      "value": string  // only present when type is "kpi" — a single headline number/text, labels/datasets omitted\n'
            + '    }\n'
            + '  ]\n'
            + '}\n'
            + 'Use several widgets of different chart types when the underlying data has multiple dimensions '
            + '(e.g. a radar chart across risk dimensions, a doughnut for an overall score, a bar chart for a '
            + 'breakdown, a line chart for a trend over time, kpi cards for single headline numbers). '
            + 'Return raw JSON only, nothing else.';
    }

//  "type": "bar" | "line" | "doughnut" | "pie" | "radar" | "polarArea" | "kpi",\n'

    /**
     * Pulls the text content out of Claude's response envelope,
     * strips any markdown fences the model adds despite instructions,
     * and validates the result is actually parseable JSON before
     * handing it back to the client.
     */
    @TestVisible
    private static String extractJsonFromClaudeResponse(String responseBody) {
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        List<Object> contentBlocks = (List<Object>) parsed.get('content');
        if (contentBlocks == null || contentBlocks.isEmpty()) {
            throw new AuraHandledException('Claude returned no content.');
        }

        String text = '';
        for (Object blockObj : contentBlocks) {
            Map<String, Object> block = (Map<String, Object>) blockObj;
            if (block.get('type') == 'text') {
                text += (String) block.get('text');
            }
        }
        text = text.trim();

        if (text.startsWith('```')) {
            Integer firstNewline = text.indexOf('\n');
            text = firstNewline >= 0 ? text.substring(firstNewline + 1) : text;
            if (text.endsWith('```')) {
                text = text.substring(0, text.length() - 3);
            }
            text = text.trim();
        }

        try {
            JSON.deserializeUntyped(text);
        } catch (JSONException je) {
            throw new AuraHandledException('Claude response was not valid JSON: ' + je.getMessage());
        }

        return text;
    }
}