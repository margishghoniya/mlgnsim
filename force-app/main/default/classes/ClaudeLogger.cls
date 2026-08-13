/**
 * ==========================================================
 * Class Name    : ClaudeLogger
 * Description   : Centralized Logger for Claude AI
 * ==========================================================
 */
public without sharing class ClaudeLogger {

    /*Log Information
     */
    public static void info(String message){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        System.debug(LoggingLevel.INFO,
            '[CLAUDE INFO] ' + message);
    }

    /* Log Warning
     */
    public static void warn(String message){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        System.debug(LoggingLevel.WARN,
            '[CLAUDE WARNING] ' + message);
    }

    /* Log Error
     */
    public static void error(String message){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        System.debug(LoggingLevel.ERROR,
            '[CLAUDE ERROR] ' + message);
    }

    /*Log Exception
     */
    public static void exception(Exception ex){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        System.debug(LoggingLevel.ERROR,
            '========= CLAUDE EXCEPTION =========');

        System.debug(LoggingLevel.ERROR,
            'Message : ' + ex.getMessage());

        System.debug(LoggingLevel.ERROR,
            'Stack Trace : ' + ex.getStackTraceString());
    }

    /* Log Request
     */
    public static void request(String endpoint,
                               String requestBody){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        System.debug(LoggingLevel.INFO,
            '========= CLAUDE REQUEST =========');

        System.debug(LoggingLevel.INFO,
            'Endpoint : ' + endpoint);

        System.debug(LoggingLevel.INFO,
            'Request : ' + requestBody);

    }

    /* Log Response
     */
    public static void response(Integer statusCode, String responseBody){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        System.debug(LoggingLevel.INFO,
            '========= CLAUDE RESPONSE =========');

        System.debug(LoggingLevel.INFO,
            'Status Code : ' + statusCode);

        System.debug(LoggingLevel.INFO,
            'Response : ' + responseBody);

    }

    /*Log Token Usage
     */
    public static void usage(ClaudeWrapper.Usage usage){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        if(usage == null){
            return;
        }

        System.debug(LoggingLevel.INFO,
            '========= TOKEN USAGE =========');

        System.debug(LoggingLevel.INFO,
            'Input Tokens : ' + usage.input_tokens);

        System.debug(LoggingLevel.INFO,
            'Output Tokens : ' + usage.output_tokens);

    }

    /* Log Execution Time
     */
    public static void execution(Long milliseconds){

        if(!ClaudeConfig.ENABLE_LOGGING){
            return;
        }

        System.debug(LoggingLevel.INFO,
            'Execution Time : ' +
            milliseconds +
            ' ms');
    }
}