/**
 * ============================================================
 * DashboardParser
 * ------------------------------------------------------------
 * Responsibility
 *
 * Convert JSON String
 *              ↓
 * DashboardWrapper Object
 *
 * Future Enhancement:
 *
 * Validate JSON
 * Save Dashboard
 * Logging
 * Transformation
 *
 * ============================================================
 */

public class DashboardParser_MG {

    /**
     * Parse complete dashboard JSON
     */
    public static DashboardWrapper_MG parse(String jsonText){

        try{

            DashboardWrapper_MG dashboard =
                (DashboardWrapper_MG)JSON.deserialize(
                    jsonText,
                    DashboardWrapper_MG.class
                );

            return dashboard;

        }
        catch(Exception ex){

            throw new AuraHandledException(
                'Invalid JSON : ' + ex.getMessage()
            );

        }

    }

}