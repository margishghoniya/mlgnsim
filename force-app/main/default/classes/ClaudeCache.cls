/**
 * ==========================================================
 * Class Name    : ClaudeCache
 * Description   : Cache Manager for Claude AI
 * ==========================================================
 */
public without sharing class ClaudeCache {

    /* In-Memory Cache
     */
    private static Map<String, DashboardWrapper> dashboardCache =
        new Map<String, DashboardWrapper>();

    /*
     * String Cache
     */
    private static Map<String, String> textCache =
        new Map<String, String>();

    /**
     * Store Dashboard
     */
    public static void putDashboard(
        String key,
        DashboardWrapper dashboard){

        if(String.isBlank(key) || dashboard == null){
            return;
        }

        dashboardCache.put(key, dashboard);
    }

    /**
     * Retrieve Dashboard
     */
    public static DashboardWrapper getDashboard(String key){

        if(String.isBlank(key)){
            return null;
        }

        if(dashboardCache.containsKey(key)){
            return dashboardCache.get(key);
        }

        return null;
    }

    /**
     * Store Text
     */
    public static void putText(
        String key,
        String value){

        if(String.isBlank(key)){
            return;
        }

        textCache.put(key, value);
    }

    /**
     * Retrieve Text
     */
    public static String getText(String key){

        if(String.isBlank(key)){
            return null;
        }

        if(textCache.containsKey(key)){
            return textCache.get(key);
        }
        return null;
    }

    /**
     * Check Dashboard Exists
     */
    public static Boolean hasDashboard(String key){

        return dashboardCache.containsKey(key);
    }

    /**
     * Check Text Exists
     */
    public static Boolean hasText(String key){

        return textCache.containsKey(key);
    }

    /**
     * Remove Dashboard
     */
    public static void removeDashboard(String key){
        dashboardCache.remove(key);
    }

    /**
     * Remove Text
     */
    public static void removeText(String key){

        textCache.remove(key);
    }

    /**
     * Clear All Cache
     */
    public static void clear(){

        dashboardCache.clear();

        textCache.clear();
    }

    /**
     * Dashboard Cache Size
     */
    public static Integer dashboardSize(){

        return dashboardCache.size();

    }

    /**
     * Text Cache Size
     */
    public static Integer textSize(){

        return textCache.size();
    }
}