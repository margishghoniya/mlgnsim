public with sharing class ClaudeController {

    /*Calls Claude AI and returns dashboard data.
     */
    @AuraEnabled
    public static DashboardWrapper generateDashboard(String prompt) {

        if(String.isBlank(prompt)){
            throw new AuraHandledException('Prompt cannot be empty.');
        }
        return ClaudeService.generateDashboard(prompt);
    }

    /*Simple method to get only Claude's response.
     */
    @AuraEnabled
    public static String askClaude(String prompt){

        if(String.isBlank(prompt)){
            throw new AuraHandledException('Prompt cannot be empty.');
        }
        return ClaudeService.sendPrompt(prompt);
    }

    /*Health Check
     */
    @AuraEnabled(cacheable=true)
    public static String getStatus(){
        return 'Claude AI Service is available.';
    }

}