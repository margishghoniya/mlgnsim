@IsTest
private class ClaudeExceptionTest {

    /*
     * Test Constructor
     */
    @IsTest
    static void testConstructor() {

        ClaudeException ex =
            new ClaudeException(
                'API_ERROR',
                'Invalid API Key'
            );

        System.assertEquals(
            'API_ERROR',
            ex.errorCode
        );

        System.assertEquals(
            'Invalid API Key',
            ex.errorMessage
        );
    }

    /*
     * Test getErrorCode()
     */
    @IsTest
    static void testGetErrorCode() {

        ClaudeException ex =
            new ClaudeException(
                'AUTH_ERROR',
                'Authentication Failed'
            );

        System.assertEquals(
            'AUTH_ERROR',
            ex.getErrorCode()
        );
    }

    /*
     * Test getErrorMessage()
     */
    @IsTest
    static void testGetErrorMessage() {

        ClaudeException ex =
            new ClaudeException(
                'JSON_ERROR',
                'Invalid JSON'
            );

        System.assertEquals(
            'Invalid JSON',
            ex.getErrorMessage()
        );
    }

    /*
     * Test getMessage() with Error Code
     */
    @IsTest
    static void testGetMessageWithCode() {

        ClaudeException ex =
            new ClaudeException(
                'API_ERROR',
                'Connection Failed'
            );

        System.assertEquals(
            'API_ERROR : Connection Failed',
            ex.getMessage()
        );
    }

    /*
     * Test getMessage() without Error Code
     */
    @IsTest
    static void testGetMessageWithoutCode() {

        ClaudeException ex =
            new ClaudeException(
                '',
                'Unknown Error'
            );

        System.assertEquals(
            'Unknown Error',
            ex.getMessage()
        );
    }

    /*
     * Test getMessage() with Null Error Code
     */
    @IsTest
    static void testGetMessageWithNullCode() {

        ClaudeException ex =
            new ClaudeException(
                null,
                'Server Error'
            );

        System.assertEquals(
            'Server Error',
            ex.getMessage()
        );
    }
}