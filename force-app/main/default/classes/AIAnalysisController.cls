/**
 * AIAnalysisController
 * -----------------------------------------------------------------
 * Calls the third-party FastAPI mini-agent for a live (non-persisted)
 * AI risk analysis of a Case, and returns a normalized wrapper to LWC.
 *
 * Auth + endpoint are resolved entirely via the Named Credential
 * "AI_Agent_Service" — no URL, key, or token lives in this class.
 * Configure that Named Credential in Setup before use:
 *   Setup > Named Credentials > New Named Credential
 *     - URL: https://your-fastapi-host.example.com
 *     - Identity Type: Named Principal (or Per-User, depending on your auth model)
 *     - Auth Protocol: match whatever the FastAPI service expects
 *       (API Key custom header, OAuth 2.0 Client Credentials, etc.)
 */
public with sharing class AIAnalysisController {

    private static final String NAMED_CREDENTIAL = 'callout:AI_Agent_Service';
    private static final Integer CALLOUT_TIMEOUT_MS = 20000; // keep well under the 120s governor ceiling

    /**
     * Fetches a fresh AI analysis for the given Case.
     * Not cacheable — this is a live call to an external agent, on demand
     * (e.g. triggered by a "Refresh Analysis" button), not on every page load.
     */
    @AuraEnabled
    public static AIAnalysisResponse getAIAnalysis(Id caseId) {
        if (caseId == null) {
            throw new AuraHandledException('A Case Id is required.');
        }

        // Pull the minimum context the agent needs. Extend this SOQL
        // as your agent's prompt/context requirements grow.
        Case c = [
            SELECT Id, CaseNumber, Account.Name, Status, Subject
            FROM Case
            WHERE Id = :caseId
            WITH USER_MODE
            LIMIT 1
        ];

        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + '/analyze-case');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(CALLOUT_TIMEOUT_MS);

        Map<String, Object> body = new Map<String, Object>{
            'caseId' => c.Id,
            'caseNumber' => c.CaseNumber,
            'accountName' => c.Account != null ? c.Account.Name : null,
            'status' => c.Status
        };
        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
        } catch (CalloutException ce) {
            throw new AuraHandledException('Could not reach the AI agent: ' + ce.getMessage());
        }

        if (res.getStatusCode() != 200) {
            throw new AuraHandledException(
                'AI agent returned an error (' + res.getStatusCode() + '): ' + res.getStatus()
            );
        }

        return parseResponse(res.getBody());
    }

    /**
     * Deserializes the agent's JSON into a typed wrapper.
     * Kept separate from the callout so it's independently unit-testable
     * with a static JSON fixture (no mock callout needed for this part).
     */
    @TestVisible
    private static AIAnalysisResponse parseResponse(String jsonBody) {
        try {
            return (AIAnalysisResponse) JSON.deserialize(jsonBody, AIAnalysisResponse.class);
        } catch (JSONException je) {
            throw new AuraHandledException('Unexpected response shape from AI agent: ' + je.getMessage());
        }
    }

    // -----------------------------------------------------------------
    // Wrapper classes — shape mirrors the FastAPI agent's response body.
    // Keep these in sync with your agent's Pydantic response model.
    // -----------------------------------------------------------------

    public class AIAnalysisResponse {
        @AuraEnabled public String recommendation;      // e.g. "REVIEW"
        @AuraEnabled public Decimal confidenceScore;     // e.g. 87
        @AuraEnabled public String overallRisk;          // e.g. "MEDIUM"
        @AuraEnabled public String modelVersion;         // e.g. "v2.3"
        @AuraEnabled public Datetime analyzedAt;
        @AuraEnabled public List<DimensionResult> dimensions;
        @AuraEnabled public List<String> topContributingFactors;
        @AuraEnabled public List<KeyFinding> keyFindings;
    }

    public class DimensionResult {
        @AuraEnabled public String label;        // e.g. "Debt Exposure"
        @AuraEnabled public String riskLevel;    // "LOW" | "MEDIUM" | "HIGH" | "PASSED"
        @AuraEnabled public Decimal confidence;  // e.g. 90 (percent)
        @AuraEnabled public String explanation;
    }

    public class KeyFinding {
        @AuraEnabled public String text;
        @AuraEnabled public String severity; // "positive" | "warning" | "negative"
    }
}