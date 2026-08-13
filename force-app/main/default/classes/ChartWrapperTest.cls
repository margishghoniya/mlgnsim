@IsTest
private class ChartWrapperTest {

    /*
     * Test ChartWrapper Constructor
     */
    @IsTest
    static void testChartWrapperConstructor() {

        ChartWrapper chart = new ChartWrapper();

        System.assertNotEquals(null, chart.labels);
        System.assertNotEquals(null, chart.datasets);

        System.assertEquals(0, chart.labels.size());
        System.assertEquals(0, chart.datasets.size());
    }

    /*
     * Test DataSet Constructor
     */
    @IsTest
    static void testDataSetConstructor() {

        ChartWrapper.DataSet ds = new ChartWrapper.DataSet();

        System.assertNotEquals(null, ds.data);
        System.assertNotEquals(null, ds.backgroundColor);
        System.assertNotEquals(null, ds.borderColor);

        System.assertEquals(0, ds.data.size());
        System.assertEquals(0, ds.backgroundColor.size());
        System.assertEquals(0, ds.borderColor.size());

        System.assertEquals(1, ds.borderWidth);
        System.assertEquals(false, ds.fill);
    }

    /*
     * Test Chart Values
     */
    @IsTest
    static void testChartData() {

        ChartWrapper chart = new ChartWrapper();

        chart.title = 'Loan Risk Analysis';
        chart.chartType = 'bar';

        chart.labels.add('January');
        chart.labels.add('February');
        chart.labels.add('March');

        ChartWrapper.DataSet ds = new ChartWrapper.DataSet();

        ds.label = 'Revenue';

        ds.data.add(120000);
        ds.data.add(145000);
        ds.data.add(160000);

        ds.backgroundColor.add('#4CAF50');
        ds.backgroundColor.add('#2196F3');
        ds.backgroundColor.add('#FFC107');

        ds.borderColor.add('#388E3C');
        ds.borderColor.add('#1976D2');
        ds.borderColor.add('#FFA000');

        ds.borderWidth = 2;
        ds.fill = true;

        chart.datasets.add(ds);

        System.assertEquals('Loan Risk Analysis', chart.title);
        System.assertEquals('bar', chart.chartType);

        System.assertEquals(3, chart.labels.size());
        System.assertEquals('January', chart.labels[0]);
        System.assertEquals('February', chart.labels[1]);
        System.assertEquals('March', chart.labels[2]);

        System.assertEquals(1, chart.datasets.size());

        System.assertEquals('Revenue', chart.datasets[0].label);

        System.assertEquals(3, chart.datasets[0].data.size());
        System.assertEquals(120000, chart.datasets[0].data[0]);
        System.assertEquals(145000, chart.datasets[0].data[1]);
        System.assertEquals(160000, chart.datasets[0].data[2]);

        System.assertEquals(3, chart.datasets[0].backgroundColor.size());
        System.assertEquals(3, chart.datasets[0].borderColor.size());

        System.assertEquals(2, chart.datasets[0].borderWidth);
        System.assertEquals(true, chart.datasets[0].fill);
    }

    /*
     * Test Multiple Datasets
     */
    @IsTest
    static void testMultipleDatasets() {

        ChartWrapper chart = new ChartWrapper();

        ChartWrapper.DataSet ds1 = new ChartWrapper.DataSet();
        ds1.label = 'Revenue';

        ChartWrapper.DataSet ds2 = new ChartWrapper.DataSet();
        ds2.label = 'Expenses';

        chart.datasets.add(ds1);
        chart.datasets.add(ds2);

        System.assertEquals(2, chart.datasets.size());
        System.assertEquals('Revenue', chart.datasets[0].label);
        System.assertEquals('Expenses', chart.datasets[1].label);
    }
}