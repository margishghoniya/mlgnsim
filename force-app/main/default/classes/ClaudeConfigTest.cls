@IsTest
private class ClaudeConfigTest {

    @IsTest
    static void testClaudeConfiguration() {

        Test.startTest();

        // Named Credential
        System.assertEquals(
            'callout:ClaudeAI',
            ClaudeConfig.NAMED_CREDENTIAL
        );

        // Endpoint
        System.assertEquals(
            'callout:ClaudeAI/v1/messages',
            ClaudeConfig.MESSAGE_ENDPOINT
        );

        // Model
        System.assertEquals(
            'claude-sonnet-5',
            ClaudeConfig.MODEL
        );

        // API Version
        System.assertEquals(
            '2023-06-01',
            ClaudeConfig.API_VERSION
        );

        // Maximum Tokens
        System.assertEquals(
            4000,
            ClaudeConfig.MAX_TOKENS
        );

        // Timeout
        System.assertEquals(
            120000,
            ClaudeConfig.TIMEOUT
        );

        // Content Type
        System.assertEquals(
            'application/json',
            ClaudeConfig.CONTENT_TYPE
        );

        // System Prompt
        System.assert(
            ClaudeConfig.SYSTEM_PROMPT.contains('Salesforce AI assistant')
        );

        System.assert(
            ClaudeConfig.SYSTEM_PROMPT.contains('structured JSON')
        );

        // Dashboard Prompt
        System.assert(
            ClaudeConfig.DASHBOARD_PROMPT.contains('dashboard')
        );

        System.assert(
            ClaudeConfig.DASHBOARD_PROMPT.contains('JSON')
        );

        // Logging Flag
        System.assertEquals(
            true,
            ClaudeConfig.ENABLE_LOGGING
        );

        // Debug Flag
        System.assertEquals(
            true,
            ClaudeConfig.DEBUG
        );

        Test.stopTest();
    }

    @IsTest
    static void testConstantsNotNull() {

        System.assertNotEquals(
            null,
            ClaudeConfig.NAMED_CREDENTIAL
        );

        System.assertNotEquals(
            null,
            ClaudeConfig.MESSAGE_ENDPOINT
        );

        System.assertNotEquals(
            null,
            ClaudeConfig.MODEL
        );

        System.assertNotEquals(
            null,
            ClaudeConfig.API_VERSION
        );

        System.assertNotEquals(
            null,
            ClaudeConfig.CONTENT_TYPE
        );

        System.assertNotEquals(
            null,
            ClaudeConfig.SYSTEM_PROMPT
        );

        System.assertNotEquals(
            null,
            ClaudeConfig.DASHBOARD_PROMPT
        );
    }
}