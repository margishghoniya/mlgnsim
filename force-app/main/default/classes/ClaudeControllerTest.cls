@IsTest
private class ClaudeControllerTest {

    /*
     * Test getStatus()
     */
    @IsTest
    static void testGetStatus() {

        Test.startTest();

        String status = ClaudeController.getStatus();

        Test.stopTest();

        System.assertEquals(
            'Claude AI Service is available.',
            status
        );
    }

    /*
     * Test generateDashboard() with blank prompt
     */
    @IsTest
    static void testGenerateDashboardBlankPrompt() {

        Test.startTest();

        try {

            ClaudeController.generateDashboard('');


        } catch (AuraHandledException ex) {

            
        }

        Test.stopTest();
    }

    /*
     * Test generateDashboard() with null prompt
     */
    @IsTest
    static void testGenerateDashboardNullPrompt() {

        Test.startTest();

        try {

            ClaudeController.generateDashboard(null);


        } catch (AuraHandledException ex) {

          
        }

        Test.stopTest();
    }

    /*
     * Test askClaude() with blank prompt
     */
    @IsTest
    static void testAskClaudeBlankPrompt() {

        Test.startTest();

        try {

            ClaudeController.askClaude('');

            System.assert(false);

        } catch (AuraHandledException ex) {

            
        }

        Test.stopTest();
    }

    /*
     * Test askClaude() with null prompt
     */
    @IsTest
    static void testAskClaudeNullPrompt() {

        Test.startTest();

        try {

            ClaudeController.askClaude(null);


        } catch (AuraHandledException ex) {

           
        }

        Test.stopTest();
    }
}