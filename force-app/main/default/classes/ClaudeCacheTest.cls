@IsTest
private class ClaudeCacheTest {

    /*
     * Test Dashboard Cache
     */
    @IsTest
    static void testDashboardCache() {

        ClaudeCache.clear();

        DashboardWrapper dashboard = new DashboardWrapper();
        dashboard.dashboardTitle = 'Loan Dashboard';

        // Put
        ClaudeCache.putDashboard('D1', dashboard);

        // Has
        System.assertEquals(true, ClaudeCache.hasDashboard('D1'));

        // Get
        DashboardWrapper result = ClaudeCache.getDashboard('D1');

        System.assertNotEquals(null, result);
        System.assertEquals('Loan Dashboard', result.dashboardTitle);

        // Size
        System.assertEquals(1, ClaudeCache.dashboardSize());

        // Remove
        ClaudeCache.removeDashboard('D1');

        System.assertEquals(false, ClaudeCache.hasDashboard('D1'));
        System.assertEquals(null, ClaudeCache.getDashboard('D1'));
        System.assertEquals(0, ClaudeCache.dashboardSize());
    }

    /*
     * Test Text Cache
     */
    @IsTest
    static void testTextCache() {

        ClaudeCache.clear();

        ClaudeCache.putText('TXT1', 'Claude AI Response');

        System.assertEquals(true, ClaudeCache.hasText('TXT1'));
        System.assertEquals('Claude AI Response',
                            ClaudeCache.getText('TXT1'));

        System.assertEquals(1,
                            ClaudeCache.textSize());

        ClaudeCache.removeText('TXT1');

        System.assertEquals(false,
                            ClaudeCache.hasText('TXT1'));

        System.assertEquals(null,
                            ClaudeCache.getText('TXT1'));

        System.assertEquals(0,
                            ClaudeCache.textSize());
    }

    /*
     * Test Clear Cache
     */
    @IsTest
    static void testClearCache() {

        ClaudeCache.clear();

        DashboardWrapper dashboard = new DashboardWrapper();

        ClaudeCache.putDashboard('D2', dashboard);
        ClaudeCache.putText('TXT2', 'Sample');

        System.assertEquals(1,
                            ClaudeCache.dashboardSize());

        System.assertEquals(1,
                            ClaudeCache.textSize());

        ClaudeCache.clear();

        System.assertEquals(0,
                            ClaudeCache.dashboardSize());

        System.assertEquals(0,
                            ClaudeCache.textSize());

        System.assertEquals(null,
                            ClaudeCache.getDashboard('D2'));

        System.assertEquals(null,
                            ClaudeCache.getText('TXT2'));
    }

    /*
     * Test Null Dashboard
     */
    @IsTest
    static void testNullDashboard() {

        ClaudeCache.clear();

        ClaudeCache.putDashboard(null, new DashboardWrapper());
        ClaudeCache.putDashboard('', new DashboardWrapper());
        ClaudeCache.putDashboard('KEY', null);

        System.assertEquals(0,
                            ClaudeCache.dashboardSize());

        System.assertEquals(null,
                            ClaudeCache.getDashboard(null));

        System.assertEquals(null,
                            ClaudeCache.getDashboard(''));

    }

    /*
     * Test Null Text
     */
    @IsTest
    static void testNullText() {

        ClaudeCache.clear();

        ClaudeCache.putText(null, 'ABC');
        ClaudeCache.putText('', 'ABC');

        System.assertEquals(0,
                            ClaudeCache.textSize());

        System.assertEquals(null,
                            ClaudeCache.getText(null));

        System.assertEquals(null,
                            ClaudeCache.getText(''));
    }

    /*
     * Test Multiple Entries
     */
    @IsTest
    static void testMultipleEntries() {

        ClaudeCache.clear();

        DashboardWrapper d1 = new DashboardWrapper();
        DashboardWrapper d2 = new DashboardWrapper();

        ClaudeCache.putDashboard('1', d1);
        ClaudeCache.putDashboard('2', d2);

        ClaudeCache.putText('A', 'One');
        ClaudeCache.putText('B', 'Two');

        System.assertEquals(2,
                            ClaudeCache.dashboardSize());

        System.assertEquals(2,
                            ClaudeCache.textSize());

        System.assertNotEquals(null,
                               ClaudeCache.getDashboard('1'));

        System.assertNotEquals(null,
                               ClaudeCache.getDashboard('2'));

        System.assertEquals('One',
                            ClaudeCache.getText('A'));

        System.assertEquals('Two',
                            ClaudeCache.getText('B'));
    }
}