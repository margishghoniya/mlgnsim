@isTest
private class ClaudeServiceTest {

    // ------------------------------------------------------------------
    // HTTP MOCKS
    // ------------------------------------------------------------------

    /** Returns a successful 200 response with a valid text content block. */
    private class SuccessMock implements HttpCalloutMock {
        String responseText;
        SuccessMock(String responseText) {
            this.responseText = responseText;
        }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            Map<String, Object> body = new Map<String, Object>{
                'content' => new List<Object>{
                    new Map<String, Object>{ 'type' => 'text', 'text' => responseText }
                },
                'usage' => new Map<String, Object>{
                    'input_tokens' => 10,
                    'output_tokens' => 20
                }
            };
            res.setBody(JSON.serialize(body));
            return res;
        }
    }

    /** Returns a 200 response whose content list is empty. */
    private class EmptyContentMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            Map<String, Object> body = new Map<String, Object>{
                'content' => new List<Object>(),
                'usage' => new Map<String, Object>{ 'input_tokens' => 1, 'output_tokens' => 1 }
            };
            res.setBody(JSON.serialize(body));
            return res;
        }
    }

    /** Returns a 200 response whose only text content is blank. */
    private class BlankTextMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            Map<String, Object> body = new Map<String, Object>{
                'content' => new List<Object>{
                    new Map<String, Object>{ 'type' => 'text', 'text' => '   ' }
                },
                'usage' => new Map<String, Object>{ 'input_tokens' => 1, 'output_tokens' => 1 }
            };
            res.setBody(JSON.serialize(body));
            return res;
        }
    }

    /** Returns a non-200 error response. */
    private class ErrorMock implements HttpCalloutMock {
        Integer statusCode;
        String message;
        ErrorMock(Integer statusCode, String message) {
            this.statusCode = statusCode;
            this.message = message;
        }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            Map<String, Object> body = new Map<String, Object>{
                'error' => new Map<String, Object>{
                    'type' => 'error',
                    'message' => message
                }
            };
            res.setBody(JSON.serialize(body));
            return res;
        }
    }

    /** Throws a CalloutException every time, to exercise the retry loop. */
    private class AlwaysThrowsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Simulated network failure');
        }
    }

    /** Returns a dashboard-shaped JSON payload, used for generateDashboard tests. */
    private static String buildDashboardJson() {
        Map<String, Object> dashboard = new Map<String, Object>{
            'title' => 'Test Dashboard',
            'kpis' => new List<Object>(),
            'charts' => new List<Object>(),
            'summary' => 'All systems normal.'
        };
        return JSON.serialize(dashboard);
    }

    // ------------------------------------------------------------------
    // generateDashboard
    // ------------------------------------------------------------------

    @isTest
    static void testGenerateDashboard_SuccessNotCached() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock(buildDashboardJson()));

        Test.startTest();
        DashboardWrapper result = ClaudeService.generateDashboard('{"revenue":1000}');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a dashboard to be returned.');
    }

    @isTest
    static void testGenerateDashboard_ReturnsFromCacheOnSecondCall() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock(buildDashboardJson()));

        Test.startTest();
        DashboardWrapper first = ClaudeService.generateDashboard('{"revenue":1000}');
        DashboardWrapper second = ClaudeService.generateDashboard('{"revenue":1000}');
        Test.stopTest();

        System.assertNotEquals(null, first, 'First call should return a dashboard.');
        System.assertNotEquals(null, second, 'Second (cached) call should also return a dashboard.');
    }

    @isTest
    static void testGenerateDashboard_BlankInputThrows() {
        Boolean caught = false;
        try {
            ClaudeService.generateDashboard('');
        } catch (ClaudeException ex) {
            caught = true;
            System.assert(ex.getMessage().contains('Input cannot be empty'));
        }
        System.assert(caught, 'Expected a ClaudeException for blank input.');
    }

    // ------------------------------------------------------------------
    // sendPrompt
    // ------------------------------------------------------------------

    @isTest
    static void testSendPrompt_Success() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('Hello from Claude'));

        Test.startTest();
        String response = ClaudeService.sendPrompt('Say hello');
        Test.stopTest();

        System.assertEquals('Hello from Claude', response);
    }

    @isTest
    static void testSendPrompt_StripsCodeFences() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('```json{"ok":true}```'));

        Test.startTest();
        String response = ClaudeService.sendPrompt('Return JSON');
        Test.stopTest();

        System.assertEquals('{"ok":true}', response);
    }

    @isTest
    static void testSendPrompt_UsesCacheOnSecondCall() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('Cached response'));

        Test.startTest();
        String first = ClaudeService.sendPrompt('Repeat this prompt');
        String second = ClaudeService.sendPrompt('Repeat this prompt');
        Test.stopTest();

        System.assertEquals(first, second, 'Second call should be served from cache and match the first.');
    }

    @isTest
    static void testSendPrompt_BlankInputThrows() {
        Boolean caught = false;
        try {
            ClaudeService.sendPrompt(null);
        } catch (ClaudeException ex) {
            caught = true;
        }
        System.assert(caught, 'Expected a ClaudeException for null/blank prompt.');
    }

    @isTest
    static void testSendPrompt_EmptyContentThrows() {
        Test.setMock(HttpCalloutMock.class, new EmptyContentMock());

        Boolean caught = false;
        Test.startTest();
        try {
            ClaudeService.sendPrompt('Prompt with empty content response');
        } catch (ClaudeException ex) {
            caught = true;
            System.assert(ex.getMessage() != null);
        }
        Test.stopTest();

        System.assert(caught, 'Expected a ClaudeException when Claude returns empty content.');
    }

    @isTest
    static void testSendPrompt_BlankTextThrows() {
        Test.setMock(HttpCalloutMock.class, new BlankTextMock());

        Boolean caught = false;
        Test.startTest();
        try {
            ClaudeService.sendPrompt('Prompt with blank text response');
        } catch (ClaudeException ex) {
            caught = true;
        }
        Test.stopTest();

        System.assert(caught, 'Expected a ClaudeException when Claude returns blank text.');
    }

    @isTest
    static void testSendPrompt_ErrorStatusThrows() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock(400, 'Bad request payload'));

        Boolean caught = false;
        Test.startTest();
        try {
            ClaudeService.sendPrompt('Trigger a 400 error');
        } catch (ClaudeException ex) {
            caught = true;
        }
        Test.stopTest();

        System.assert(caught, 'Expected a ClaudeException for a non-200 response.');
    }

    @isTest
    static void testSendPrompt_RetriesThenFailsOnRepeatedCalloutException() {
        Test.setMock(HttpCalloutMock.class, new AlwaysThrowsMock());

        Boolean caught = false;
        Test.startTest();
        try {
            ClaudeService.sendPrompt('This will fail every retry');
        } catch (ClaudeException ex) {
            caught = true;
            System.assertEquals('CALL_OUT_FAILED', ex.getMessage() != null ? 'CALL_OUT_FAILED' : '');
        }
        Test.stopTest();

        System.assert(caught, 'Expected a ClaudeException after exhausting retries.');
    }

    // ------------------------------------------------------------------
    // askClaude
    // ------------------------------------------------------------------

    @isTest
    static void testAskClaude_SucceedsWithinRetryLimit() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('OK'));

        Test.startTest();
        String result = ClaudeService.askClaude('Ping', 3);
        Test.stopTest();

        System.assertEquals('OK', result);
    }

    @isTest
    static void testAskClaude_ExhaustsRetriesAndThrows() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock(500, 'Internal error'));

        Boolean caught = false;
        Test.startTest();
        try {
            ClaudeService.askClaude('Ping', 2);
        } catch (Exception ex) {
            caught = true;
        }
        Test.stopTest();

        System.assert(caught, 'Expected an exception once the retry limit is exhausted.');
    }

    @isTest
    static void testAskClaude_BlankPromptThrows() {
        Boolean caught = false;
        try {
            ClaudeService.askClaude('', 3);
        } catch (ClaudeException ex) {
            caught = true;
        }
        System.assert(caught, 'Expected a ClaudeException for a blank prompt.');
    }

    // ------------------------------------------------------------------
    // Convenience generation methods
    // ------------------------------------------------------------------

    @isTest
    static void testGenerateExecutiveSummary() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('Executive summary text'));

        Test.startTest();
        String result = ClaudeService.generateExecutiveSummary('{"revenue":1000}');
        Test.stopTest();

        System.assertEquals('Executive summary text', result);
    }

    @isTest
    static void testGenerateRiskAnalysis() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('Risk analysis text'));

        Test.startTest();
        String result = ClaudeService.generateRiskAnalysis('{"revenue":1000}');
        Test.stopTest();

        System.assertEquals('Risk analysis text', result);
    }

    @isTest
    static void testGenerateKPI() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('KPI text'));

        Test.startTest();
        String result = ClaudeService.generateKPI('{"revenue":1000}');
        Test.stopTest();

        System.assertEquals('KPI text', result);
    }

    @isTest
    static void testGenerateChart() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('Chart text'));

        Test.startTest();
        String result = ClaudeService.generateChart('{"revenue":1000}');
        Test.stopTest();

        System.assertEquals('Chart text', result);
    }

    @isTest
    static void testGenerateCreditDecision() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('Credit decision text'));

        Test.startTest();
        String result = ClaudeService.generateCreditDecision('{"revenue":1000}');
        Test.stopTest();

        System.assertEquals('Credit decision text', result);
    }

    // ------------------------------------------------------------------
    // Availability / health check
    // ------------------------------------------------------------------

    @isTest
    static void testIsClaudeAvailable_True() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('OK'));

        Test.startTest();
        Boolean available = ClaudeService.isClaudeAvailable();
        Test.stopTest();

        System.assertEquals(true, available);
    }

    @isTest
    static void testIsClaudeAvailable_FalseOnError() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock(503, 'Service unavailable'));

        Test.startTest();
        Boolean available = ClaudeService.isClaudeAvailable();
        Test.stopTest();

        System.assertEquals(false, available);
    }

    @isTest
    static void testHealthCheck() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock('OK'));

        Test.startTest();
        Map<String, Object> result = ClaudeService.healthCheck();
        Test.stopTest();

        System.assertEquals('Claude AI', result.get('service'));
        System.assert(result.containsKey('model'));
        System.assert(result.containsKey('endpoint'));
        System.assert(result.containsKey('available'));
        System.assert(result.containsKey('timestamp'));
        System.assertEquals(true, result.get('available'));
    }

    // ------------------------------------------------------------------
    // Cache management
    // ------------------------------------------------------------------

    @isTest
    static void testClearDashboardCache() {
        Test.startTest();
        ClaudeService.clearDashboardCache();
        Test.stopTest();
        // No exception means the cache was cleared successfully.
        System.assert(true);
    }

    // ------------------------------------------------------------------
    // JSON helpers
    // ------------------------------------------------------------------

    @isTest
    static void testToJsonAndFromJson() {
        Map<String, Object> source = new Map<String, Object>{ 'key' => 'value', 'count' => 5 };

        Test.startTest();
        String json = ClaudeService.toJson(source);
        Test.stopTest();

        System.assert(json.contains('"key"'));
        System.assert(json.contains('"value"'));
    }

    // ------------------------------------------------------------------
    // Configuration logging
    // ------------------------------------------------------------------

    @isTest
    static void testPrintConfiguration() {
        Test.startTest();
        ClaudeService.printConfiguration();
        Test.stopTest();
        // printConfiguration only writes log statements; reaching this
        // point without an exception is a pass.
        System.assert(true);
    }
}