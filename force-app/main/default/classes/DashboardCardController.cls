/**
 * DashboardCardController
 * -----------------------------------------------------------------
 * No callouts, no persistence. Takes the raw JSON string typed/pasted
 * into the LWC's lightning-input, deserializes it server-side, and
 * returns a normalized structure so the LWC never has to branch on
 * "is this field a String or a Number" itself — Apex does that once,
 * here, for every card.
 *
 * Cards can be mixed types (kpi / chart / table) in the same array,
 * which is why this uses JSON.deserializeUntyped rather than a single
 * typed class — Apex has no native polymorphic deserialization, so
 * each card is inspected and normalized by hand into DashboardCard,
 * a single wrapper shape wide enough to cover all three kinds.
 *
 * A single bad card (unknown type, unsupported chart type, malformed
 * shape) does not fail the whole request — it comes back tagged
 * "unsupported" with a message, and every other card still renders.
 * Only a request that isn't valid JSON at all throws.
 */
public with sharing class DashboardCardController {

    @AuraEnabled
    public static DashboardResponse parseDashboardJson(String jsonInput) {
        if (String.isBlank(jsonInput)) {
            throw new AuraHandledException('No JSON provided.');
        }

        Map<String, Object> root;
        try {
            root = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid JSON: ' + e.getMessage());
        }

        List<Object> rawCards = root.containsKey('cards') ? (List<Object>) root.get('cards') : new List<Object>();

        DashboardResponse response = new DashboardResponse();
        response.cards = new List<DashboardCard>();

        for (Integer i = 0; i < rawCards.size(); i++) {
            response.cards.add(normalizeCard((Map<String, Object>) rawCards[i], i));
        }

        return response;
    }

    // -----------------------------------------------------------------
    // Normalization
    // -----------------------------------------------------------------

    private static final Set<String> VALID_CHART_TYPES = new Set<String>{
        'bar', 'line', 'doughnut', 'pie', 'radar', 'polarArea'
    };

    @TestVisible
    private static DashboardCard normalizeCard(Map<String, Object> raw, Integer idx) {
        DashboardCard card = new DashboardCard();
        card.key = 'card-' + idx;
        card.title = raw.containsKey('title') ? String.valueOf(raw.get('title')) : '';

        String type = raw.containsKey('type') ? String.valueOf(raw.get('type')) : '';

        try {
            if (type == 'kpi') {
                card.kind = 'kpi';
                card.isKpi = true;
                card.value = raw.containsKey('value') ? String.valueOf(raw.get('value')) : '';
                return card;
            }

            if (type == 'chart') {
                return normalizeChartCard(card, raw, idx);
            }

            if (type == 'table') {
                return normalizeTableCard(card, raw);
            }

            card.kind = 'unsupported';
            card.isUnsupported = true;
            card.unsupportedMessage = 'Unsupported card type: "' + type + '"';
            return card;

        } catch (Exception e) {
            // Malformed card (wrong shape, missing required field, bad cast) -
            // don't fail the whole dashboard, just this one card.
            card.kind = 'unsupported';
            card.isUnsupported = true;
            card.unsupportedMessage = 'Could not parse this card: ' + e.getMessage();
            return card;
        }
    }

    private static DashboardCard normalizeChartCard(DashboardCard card, Map<String, Object> raw, Integer idx) {
        String chartType = raw.containsKey('chart') ? String.valueOf(raw.get('chart')) : '';

        if (!VALID_CHART_TYPES.contains(chartType)) {
            card.kind = 'unsupported';
            card.isUnsupported = true;
            card.unsupportedMessage = 'Unsupported chart type: "' + chartType + '"';
            return card;
        }

        card.kind = 'chart';
        card.isChart = true;
        card.domId = 'chart-' + idx;
        card.chartType = chartType;

        card.labels = new List<String>();
        if (raw.containsKey('labels')) {
            for (Object label : (List<Object>) raw.get('labels')) {
                card.labels.add(String.valueOf(label));
            }
        }

        card.datasets = new List<ChartDataset>();
        if (raw.containsKey('datasets')) {
            // Full multi-series form: [{ "label": ..., "data": [...] }, ...]
            for (Object dsObj : (List<Object>) raw.get('datasets')) {
                Map<String, Object> ds = (Map<String, Object>) dsObj;
                ChartDataset dataset = new ChartDataset();
                dataset.label = ds.containsKey('label') ? String.valueOf(ds.get('label')) : card.title;
                dataset.data = toDecimalList(ds.containsKey('data') ? (List<Object>) ds.get('data') : new List<Object>());
                card.datasets.add(dataset);
            }
        } else {
            // Flat single-series form: "data": [120, 135]
            ChartDataset dataset = new ChartDataset();
            dataset.label = card.title;
            dataset.data = toDecimalList(raw.containsKey('data') ? (List<Object>) raw.get('data') : new List<Object>());
            card.datasets.add(dataset);
        }

        return card;
    }

    private static DashboardCard normalizeTableCard(DashboardCard card, Map<String, Object> raw) {
        card.kind = 'table';
        card.isTable = true;

        card.columnHeaders = new List<TableColumn>();
        List<Object> rawColumns = raw.containsKey('columns') ? (List<Object>) raw.get('columns') : new List<Object>();
        for (Integer c = 0; c < rawColumns.size(); c++) {
            TableColumn col = new TableColumn();
            col.key = card.key + '-col-' + c;
            col.label = String.valueOf(rawColumns[c]);
            card.columnHeaders.add(col);
        }

        card.rows = new List<TableRow>();
        List<Object> rawRows = raw.containsKey('rows') ? (List<Object>) raw.get('rows') : new List<Object>();
        for (Integer r = 0; r < rawRows.size(); r++) {
            List<Object> rawRow = (List<Object>) rawRows[r];
            TableRow row = new TableRow();
            row.key = card.key + '-row-' + r;
            row.cells = new List<TableCell>();
            for (Integer c = 0; c < rawRow.size(); c++) {
                TableCell cell = new TableCell();
                cell.key = card.key + '-cell-' + r + '-' + c;
                cell.value = String.valueOf(rawRow[c]);
                row.cells.add(cell);
            }
            card.rows.add(row);
        }

        return card;
    }

    private static List<Decimal> toDecimalList(List<Object> raw) {
        List<Decimal> result = new List<Decimal>();
        for (Object o : raw) {
            if (o == null) {
                continue;
            }
            if (o instanceof Decimal) {
                result.add((Decimal) o);
            } else if (o instanceof Double) {
                // JSON.deserializeUntyped represents JSON numbers as Double at
                // runtime - a direct (Decimal) cast on that throws a
                // System.TypeException, so convert explicitly instead.
                result.add(Decimal.valueOf((Double) o));
            } else {
                result.add(Decimal.valueOf(String.valueOf(o)));
            }
        }
        return result;
    }

    // -----------------------------------------------------------------
    // Wrapper classes - one shape wide enough for kpi / chart / table / unsupported
    // -----------------------------------------------------------------

    public class DashboardResponse {
        @AuraEnabled public List<DashboardCard> cards;
    }

    public class DashboardCard {
        @AuraEnabled public String key;
        @AuraEnabled public String kind; // 'kpi' | 'chart' | 'table' | 'unsupported'
        @AuraEnabled public String title;

        // kind = 'kpi'
        @AuraEnabled public Boolean isKpi = false;
        @AuraEnabled public String value;

        // kind = 'chart'
        @AuraEnabled public Boolean isChart = false;
        @AuraEnabled public String domId;
        @AuraEnabled public String chartType;
        @AuraEnabled public List<String> labels;
        @AuraEnabled public List<ChartDataset> datasets;

        // kind = 'table'
        @AuraEnabled public Boolean isTable = false;
        @AuraEnabled public List<TableColumn> columnHeaders;
        @AuraEnabled public List<TableRow> rows;

        // kind = 'unsupported'
        @AuraEnabled public Boolean isUnsupported = false;
        @AuraEnabled public String unsupportedMessage;
    }

    public class ChartDataset {
        @AuraEnabled public String label;
        @AuraEnabled public List<Decimal> data;
    }

    public class TableColumn {
        @AuraEnabled public String key;
        @AuraEnabled public String label;
    }

    public class TableRow {
        @AuraEnabled public String key;
        @AuraEnabled public List<TableCell> cells;
    }

    public class TableCell {
        @AuraEnabled public String key;
        @AuraEnabled public String value;
    }
}