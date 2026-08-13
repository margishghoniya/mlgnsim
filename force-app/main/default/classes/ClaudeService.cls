/**
* ==========================================================
* Class Name    : ClaudeService
* Description   : Enterprise Claude AI Service
* ==========================================================
*/
public without sharing class ClaudeService {
    
    /**
* Generate AI Dashboard
*/
    public static DashboardWrapper generateDashboard(String businessData) {
        
        validateInput(businessData);
        
        String prompt = ClaudePromptBuilder.buildDashboardPrompt(businessData);
        
        String cacheKey = generateCacheKey(prompt);
        
        if (ClaudeCache.hasDashboard(cacheKey)) {
            
            ClaudeLogger.info('Dashboard returned from cache.');
            
            return ClaudeCache.getDashboard(cacheKey);
        }
        
        Long startTime = DateTime.now().getTime();
        
        try {
            
            ClaudeLogger.info('Generating dashboard from Claude AI.');
            
            String responseText = sendPrompt(prompt);
            
            System.debug('STEP 2');
            System.debug(responseText);
            
            DashboardWrapper dashboard = DashboardParser.parseDashboard(responseText);
            
                System.debug('STEP 3');

            
            ClaudeCache.putDashboard(cacheKey,dashboard);
            
            Long execution = DateTime.now().getTime() - startTime;
            
            ClaudeLogger.execution(execution);
            
            return dashboard;
            
        }
        catch (Exception ex) {
            
            System.debug('ERROR MESSAGE: ' + ex.getMessage());

    System.debug(ex.getStackTraceString());

            ClaudeLogger.exception(ex);
            throw ex;
        }
    }
    
    /*** Generic Claude Prompt*/
    public static String sendPrompt(String prompt) {
        
        validateInput(prompt);
        
        String cacheKey = generateCacheKey(prompt);
        
        if (ClaudeCache.hasText(cacheKey)) {
            
            ClaudeLogger.info('Text response returned from cache.');
            
            return ClaudeCache.getText(cacheKey);
        }
        
        Long startTime = DateTime.now().getTime();
        
        try {
            
            ClaudeWrapper.Request requestWrapper = buildRequest(prompt);
            
            String requestBody = System.JSON.serialize(requestWrapper);
            
            ClaudeLogger.request(ClaudeConfig.MESSAGE_ENDPOINT,requestBody);
            
            HttpResponse response = executeCallout(requestBody);
            
            ClaudeLogger.response(response.getStatusCode(), response.getBody());
            
            String responseText = processResponse(response);
            
            ClaudeCache.putText(cacheKey, responseText);
            
            Long execution = DateTime.now().getTime() - startTime;
            
            ClaudeLogger.execution(execution);
            
            return responseText;
            
        }
        catch (Exception ex) {      
            ClaudeLogger.exception(ex);
            throw ex;
        }
    }
    
    /**
* Validate Input
*/
    private static void validateInput(String input) {
            
            if (String.isBlank(input)) {
                
                throw new ClaudeException('VALIDATION_ERROR', 'Input cannot be empty.');
            }
        }
    
    /**
* Build Claude Request
*/
    private static ClaudeWrapper.Request buildRequest(String prompt) {
            
            ClaudeWrapper.Content content = new ClaudeWrapper.Content();
            
            content.type = 'text';
            content.text = prompt;
            
            ClaudeWrapper.Message message = new ClaudeWrapper.Message();
            
            message.role = 'user';
            message.content = new List<ClaudeWrapper.Content>{content};
                            
                            ClaudeWrapper.Request request = new ClaudeWrapper.Request();
            
            request.model = ClaudeConfig.MODEL;
            
            request.max_tokens = ClaudeConfig.MAX_TOKENS;
            
            // request.temperature = ClaudeConfig.TEMPERATURE;
            
            request.messages = new List<ClaudeWrapper.Message>{message};
            return request;
        }
    
    /**
* Execute HTTP Callout
*/
    private static HttpResponse executeCallout(String requestBody) {
        
        Integer retryCount = 0;
        
        Exception lastException;
        
        while (retryCount < 3) {
            
            try {
                
                HttpRequest request = Utility.createRequest(ClaudeConfig.MESSAGE_ENDPOINT,'POST',requestBody);
                
                request.setTimeout(ClaudeConfig.TIMEOUT);
                
                request.setHeader('anthropic-version',ClaudeConfig.API_VERSION);
                
                Http http = new Http();
                
                HttpResponse response = http.send(request);
                
                System.debug('===== CLAUDE RESPONSE =====');
                System.debug(response.getBody());
                return response;
                
            }
            catch (CalloutException ex) {
                
                lastException = ex;
                
                retryCount++;
                
                ClaudeLogger.warn('Retry Attempt : ' +retryCount);
            }
        }
        throw new ClaudeException('CALL_OUT_FAILED',lastException.getMessage());
    }
    
    /* Process Claude Response
*/
    private static String processResponse(HttpResponse response) {
            
            if (response == null) {
                
                throw new ClaudeException('NULL_RESPONSE','No response received.');
            }
            
            Integer statusCode = response.getStatusCode();
            
            String body = response.getBody();
            
            if (statusCode == 200) {
                
                ClaudeWrapper.Response result = DashboardParser.parseClaudeResponse(body);
                System.debug('===== CONTENT SIZE =====');
                System.debug(result.content.size());

                ClaudeLogger.usage(result.usage);
                
                if (result.content == null || result.content.isEmpty()) {
                        throw new ClaudeException('EMPTY_RESPONSE','Claude returned empty content.');
                    }
                
                String responseText = '';
                
                for (ClaudeWrapper.ResponseContent item : result.content) {
                    
                    if (item.type == 'text' && !String.isBlank(item.text)) {
                        
                        responseText = item.text;
                        break;
                    }
                }

                responseText = responseText.replace('```json', '');
                responseText = responseText.replace('```', '');
                responseText = responseText.trim();
                
                if (String.isBlank(responseText)) {
                    throw new ClaudeException('EMPTY_RESPONSE','Claude returned an empty text response.');
                }
                System.debug('===== DASHBOARD JSON =====');
                System.debug(responseText);
                return responseText;
                
            }
            ClaudeWrapper.ErrorResponse error = DashboardParser.parseError(body);
            
            throw new ClaudeException( String.valueOf(statusCode), error.error.message);
            
        }
    
    /*** Ask Claude with Retry
*/
    public static String askClaude(String prompt,Integer retryLimit) {
            
            validateInput(prompt);
            Integer attempts = 0;
            while (attempts < retryLimit) {
                
                try {
                    return sendPrompt(prompt);
                }
                catch (Exception ex) {
                    attempts++;
                    ClaudeLogger.warn('Retry ' + attempts + ' due to ' + ex.getMessage());
                    if (attempts >= retryLimit) {
                        throw ex;
                    }
                }
            }
            
            throw new ClaudeException('UNKNOWN_ERROR','Unable to process request.');
        }
    
    /**
* Generate Executive Summary
*/
    public static String generateExecutiveSummary(String businessData) {
            
            String prompt = ClaudePromptBuilder.buildExecutiveSummaryPrompt(businessData);
            
            return sendPrompt(prompt);
        }
    
    /**
* Generate Risk Analysis
*/
    public static String generateRiskAnalysis(String businessData) {
            
            String prompt = ClaudePromptBuilder.buildRiskPrompt(businessData);
            return sendPrompt(prompt);
        }
    
    /**
* Generate KPI
*/
    public static String generateKPI(String businessData) {
            
            String prompt = ClaudePromptBuilder.buildKpiPrompt(businessData);
            return sendPrompt(prompt);
        }
    
    /**
* Generate Chart
*/
    public static String generateChart(String businessData) {
            
            String prompt = ClaudePromptBuilder.buildChartPrompt(businessData);
            return sendPrompt(prompt);
        }
    
    /**
* Generate Credit Decision
*/
    public static String generateCreditDecision(String businessData) {
            
            String prompt = ClaudePromptBuilder.buildCreditDecisionPrompt(businessData);
            return sendPrompt(prompt);
        }
    
    /**
* Generate Cache Key
*/
    private static String generateCacheKey(String input) {
        
        Blob hash = Crypto.generateDigest('SHA-256',Blob.valueOf(input));
        return EncodingUtil.convertToHex(hash);
        
    }
    
    /**
* Clear Dashboard Cache
*/
    public static void clearDashboardCache() {
        
        ClaudeCache.clear();
        
        ClaudeLogger.info('Dashboard cache cleared.');
    }
    
    /**
* Check Claude Availability
*/
    public static Boolean isClaudeAvailable() {
        
        try {
            
            String prompt = 'Reply with the word OK only.';
            
            String response = sendPrompt(prompt);
            
            return !String.isBlank(response);
            
        }
        catch (Exception ex) {
            
            ClaudeLogger.exception(ex);
            
            return false;
            
        }
        
    }
    
    /**
* Claude Health Check
*/
    public static Map<String, Object> healthCheck() {
        
        Map<String, Object> result = new Map<String, Object>();
        
        result.put('service','Claude AI');
        
        result.put('model',ClaudeConfig.MODEL);
        
        result.put('endpoint',ClaudeConfig.MESSAGE_ENDPOINT);
        
        result.put('available',isClaudeAvailable());
        
        result.put('timestamp',System.now());
        
        return result;
    }
    
    /*** Serialize Object*/
    public static String toJson(Object obj) {
        
        return System.JSON.serializePretty(obj);
    }
    
    /**
* Deserialize Object
*/
    public static Object fromJson(
        String json,
        Type apexType
    ) {
        
        return System.JSON.deserialize(
            json,
            apexType
        );
    }
    
    /*** Log Configuration
*/
    public static void printConfiguration() {
        
        ClaudeLogger.info(
            '========== Claude Configuration =========='
        );
        
        ClaudeLogger.info(
            'Model : ' +
            ClaudeConfig.MODEL
        );
        
        ClaudeLogger.info(
            'Endpoint : ' +
            ClaudeConfig.MESSAGE_ENDPOINT
        );
        
        ClaudeLogger.info(
            'API Version : ' +
            ClaudeConfig.API_VERSION
        );
        
        ClaudeLogger.info(
            'Timeout : ' +
            ClaudeConfig.TIMEOUT
        );
        
        ClaudeLogger.info(
            'Max Tokens : ' +
            ClaudeConfig.MAX_TOKENS
        );
    }
    
}