/**
 * ============================================================
 * DashboardController
 * ------------------------------------------------------------
 * This class is called directly from LWC.
 *
 * Responsibility:
 * 1. Receive JSON String
 * 2. Call Parser
 * 3. Return DashboardWrapper
 *
 * NOTE:
 * Do NOT write business logic here.
 * ============================================================
 */

public with sharing class dashboardCtrl_MG {

    /**
     * Parse JSON received from LWC
     */
    @AuraEnabled(cacheable=false)
    public static DashboardWrapper_MG parseDashboard(String jsonText){
		system.debug('jsonText==='+jsonText);
        if(String.isBlank(jsonText)){
            throw new AuraHandledException('JSON cannot be empty.');
        }

        return DashboardParser_MG.parse(jsonText);

    }

}