@IsTest
private class ClaudeWrapperTest {

    /*
     * Test Request Wrapper
     */
    @IsTest
    static void testRequestWrapper() {

        ClaudeWrapper.Request req = new ClaudeWrapper.Request();

        req.model = 'claude-sonnet-5';
        req.max_tokens = 4000;

        ClaudeWrapper.Message msg = new ClaudeWrapper.Message();
        msg.role = 'user';

        ClaudeWrapper.Content content = new ClaudeWrapper.Content();
        content.type = 'text';
        content.text = 'Analyze this loan application';

        msg.content.add(content);
        req.messages.add(msg);

        System.assertEquals('claude-sonnet-5', req.model);
        System.assertEquals(4000, req.max_tokens);
        System.assertEquals(1, req.messages.size());
        System.assertEquals('user', req.messages[0].role);
        System.assertEquals('Analyze this loan application',
                            req.messages[0].content[0].text);
    }

    /*
     * Test Response Wrapper
     */
    @IsTest
    static void testResponseWrapper() {

        ClaudeWrapper.Response response = new ClaudeWrapper.Response();

        response.id = 'msg_001';
        response.type = 'message';
        response.role = 'assistant';
        response.model = 'claude-sonnet-5';
        response.stop_reason = 'end_turn';
        response.stop_sequence = null;

        ClaudeWrapper.ResponseContent rc =
            new ClaudeWrapper.ResponseContent();

        rc.type = 'text';
        rc.text = '{"overallScore":91}';

        response.content =
            new List<ClaudeWrapper.ResponseContent>();

        response.content.add(rc);

        ClaudeWrapper.Usage usage =
            new ClaudeWrapper.Usage();

        usage.input_tokens = 150;
        usage.output_tokens = 250;

        response.usage = usage;

        System.assertEquals('msg_001', response.id);
        System.assertEquals('assistant', response.role);
        System.assertEquals('claude-sonnet-5', response.model);
        System.assertEquals('text', response.content[0].type);
        System.assertEquals('{"overallScore":91}',
                            response.content[0].text);
        System.assertEquals(150,
                            response.usage.input_tokens);
        System.assertEquals(250,
                            response.usage.output_tokens);
    }

    /*
     * Test Error Wrapper
     */
    @IsTest
    static void testErrorWrapper() {

        ClaudeWrapper.Error err =
            new ClaudeWrapper.Error();

        err.type = 'invalid_request_error';
        err.message = 'Invalid API Key';

        ClaudeWrapper.ErrorResponse errorResponse =
            new ClaudeWrapper.ErrorResponse();

        errorResponse.type = 'error';
        errorResponse.error = err;

        System.assertEquals('error',
                            errorResponse.type);

        System.assertEquals('invalid_request_error',
                            errorResponse.error.type);

        System.assertEquals('Invalid API Key',
                            errorResponse.error.message);
    }

    /*
     * Test Serialization
     */
    @IsTest
    static void testSerialization() {

        ClaudeWrapper.Request req =
            new ClaudeWrapper.Request();

        req.model = 'claude-sonnet-5';
        req.max_tokens = 2000;

        String json =
            JSON.serialize(req);

      
    }

    /*
     * Test Deserialization
     */
    @IsTest
    static void testDeserialization() {

        String json =
        '{' +
        '"id":"msg_001",' +
        '"type":"message",' +
        '"role":"assistant",' +
        '"model":"claude-sonnet-5",' +
        '"content":[{' +
        '"type":"text",' +
        '"text":"Loan Approved"' +
        '}],' +
        '"stop_reason":"end_turn",' +
        '"usage":{' +
        '"input_tokens":120,' +
        '"output_tokens":250' +
        '}' +
        '}';

    }
}