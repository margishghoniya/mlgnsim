/**
 * ============================================================
 * Dashboard Wrapper
 *
 * This class represents complete JSON.
 *
 * ============================================================
 */

public class DashboardWrapper_MG {

   @AuraEnabled
    public Dashboard dashboard;

    @AuraEnabled
    public List<Widget> widgets;

    //====================================================
    // Dashboard Header
    //====================================================

    public class Dashboard{

        @AuraEnabled public String title;
        @AuraEnabled public String loan;
        @AuraEnabled public String customer;
        @AuraEnabled public String generated;

    }

    //====================================================
    // Widget
    //====================================================

    public class Widget{

        @AuraEnabled public String id;
        @AuraEnabled public String type;
        @AuraEnabled public String title;

        // KPI / Progress
        @AuraEnabled public List<KPIItem> items;

        // Chart
        @AuraEnabled public String chartType;
        @AuraEnabled public List<String> labels;
        @AuraEnabled public List<ChartSeries> series;

        // Table
        @AuraEnabled public List<String> columns;
        @AuraEnabled public List<TableRow> rows;

        // Timeline
        @AuraEnabled public List<TimelineEvent> events;

    }

    //====================================================
    // KPI
    //====================================================

    public class KPIItem{

        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String color;

    }

    //====================================================
    // Chart
    //====================================================

    public class ChartSeries{

        @AuraEnabled public String name;
        @AuraEnabled public List<Decimal> data;

    }

    //====================================================
    // Table
    //====================================================

    public class TableRow{

        @AuraEnabled public List<String> cells;

    }

    //====================================================
    // Timeline
    //====================================================

    public class TimelineEvent{

        @AuraEnabled public String title;
        @AuraEnabled public String time1;
        @AuraEnabled public String status;
        @AuraEnabled public String description;
        @AuraEnabled public String icon;

        @AuraEnabled public List<Metric> metrics;
        @AuraEnabled public List<Evidence> evidence;

    }

    //====================================================
    // Metric
    //====================================================

    public class Metric{

        @AuraEnabled public String label;
        @AuraEnabled public String value;

    }

    //====================================================
    // Evidence
    //====================================================

    public class Evidence{

        @AuraEnabled public String name;

    }

}