@IsTest
private class UtilityTest {

    /*
     * Test isNotBlank()
     */
    @IsTest
    static void testIsNotBlank() {

        Test.startTest();

        System.assertEquals(true, Utility.isNotBlank('Claude'));
        System.assertEquals(true, Utility.isNotBlank(' Salesforce '));

        System.assertEquals(false, Utility.isNotBlank(''));
        System.assertEquals(false, Utility.isNotBlank('   '));
        System.assertEquals(false, Utility.isNotBlank(null));

        Test.stopTest();
    }

    /*
     * Test nowDateTime()
     */
    @IsTest
    static void testNowDateTime() {

        Datetime dt = Utility.nowDateTime();

        System.assertNotEquals(null, dt);
        System.assert(dt <= System.now());
    }

    /*
     * Test JSON Serialization
     */
    @IsTest
    static void testToJson() {

        Map<String,Object> data = new Map<String,Object>{
            'Name' => 'Rahul',
            'Score' => 95
        };

        String json = Utility.toJson(data);

        System.assert(json.contains('Rahul'));
        System.assert(json.contains('95'));
    }

    /*
     * Test HTTP Request with Body
     */
    @IsTest
    static void testCreateRequestWithBody() {

        HttpRequest req = Utility.createRequest(
            'https://example.com/api',
            'POST',
            '{"test":"value"}'
        );

        System.assertEquals(
            'https://example.com/api',
            req.getEndpoint()
        );

        System.assertEquals(
            'POST',
            req.getMethod()
        );

        System.assertEquals(
            'application/json',
            req.getHeader('Content-Type')
        );

        System.assertEquals(
            '{"test":"value"}',
            req.getBody()
        );

       
    }

    /*
     * Test HTTP Request without Body
     */
    @IsTest
    static void testCreateRequestWithoutBody() {

        HttpRequest req = Utility.createRequest(
            'https://example.com/api',
            'GET',
            null
        );

    }

    /*
     * Test Pretty JSON
     */
    @IsTest
    static void testPrettyJson() {

        Map<String,Object> data = new Map<String,Object>{
            'Dashboard' => 'Claude AI'
        };

        String json = Utility.prettyJson(data);

        System.assert(json.contains('Claude AI'));
        System.assert(json.contains('Dashboard'));
    }

    /*
     * Test Debug Log
     */
    @IsTest
    static void testLog() {

        Test.startTest();

        Utility.log('Unit Test');

        Test.stopTest();

        // No assertion required.
        // Method executes successfully if no exception occurs.
        System.assert(true);
    }
}