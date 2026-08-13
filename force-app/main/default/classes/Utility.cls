public without sharing class Utility {

    /* Checks if a string has a value.
     */
    public static Boolean isNotBlank(String value) {
        return value != null && value.trim().length() > 0;
    }

    /* Returns current timestamp.
     */
    public static Datetime nowDateTime() {
        return Datetime.now();
    }

    /* Serialize object into JSON.
     */
    public static String toJson(Object obj) {
        return JSON.serialize(obj);
    }

    /* Deserialize JSON into Apex object.
     */
    public static Object fromJson(String jsonString, Type apexType) {
        return JSON.deserialize(jsonString, apexType);
    }

    /* Creates HTTP Request.
     */
    public static HttpRequest createRequest(
        String endpoint,
        String method,
        String body
    ) {

        HttpRequest req = new HttpRequest();

        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(120000);

        req.setHeader('Content-Type','application/json');

        if(body != null){
            req.setBody(body);
        }

        return req;
    }

    /* Pretty JSON for debugging.
     */
    public static String prettyJson(Object obj){
        return JSON.serializePretty(obj);
    }

    /* Debug helper.
     */
    public static void log(String message){
        System.debug('Claude Dashboard :: ' + message);
    }

}