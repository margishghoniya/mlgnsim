/**
 * ==========================================================
 * Class Name    : ClaudeException
 * Description   : Custom Exception Class for Claude AI
 * Author        : Rahul
 * ==========================================================
 */
public class ClaudeException extends Exception {

    /*
     * Error Code
     */
    public String errorCode;

    /*
     * Error Message
     */
    public String errorMessage;


    /*
     * Constructor
     */
    public ClaudeException(String code, String message) {

        this.errorCode = code;
        this.errorMessage = message;
    }

    /*
     * Returns Error Code
     */
    public String getErrorCode() {

        return errorCode;
    }

    /*
     * Returns Error Message
     */
    public String getErrorMessage() {

        return errorMessage;
    }

    /*
     * Returns Complete Error
     */
    public override String getMessage() {

        if(String.isBlank(errorCode)){

            return errorMessage;
        }

        return errorCode + ' : ' + errorMessage;
    }

}