import { LightningElement, api } from 'lwc';

export default class TableRenderer extends LightningElement {

	// Widget received from parent
	@api widget;

	//==============================
	// Check records available
	//==============================
	get hasData() {

		return this.widget &&
			this.widget.rows &&
			this.widget.rows.length > 0;

	}

	//==============================
	// No Data
	//==============================
	get showNoData() {

		return !this.hasData;

	}

	//==============================
	// Dynamic Table Rows
	// Generates unique ids
	//==============================
	get tableRows() {

		if (!this.hasData) {
			return [];
		}

		return this.widget.rows.map((row, rowIndex) => {

			// Support both formats:
			// 1. rows:[["A","B","C"]]
			// 2. rows:[{cells:["A","B","C"]}]

			const cells = Array.isArray(row)
				? row
				: (row.cells || []);

			return {

				id: 'ROW_' + rowIndex,

				cells: cells.map((cell, cellIndex) => {

					return {

						id: 'CELL_' + rowIndex + '_' + cellIndex,

						value: cell

					};

				})

			};

		});

	}

	//==============================
	// Number of Columns
	//==============================
	get columnCount() {

		if (!this.widget) {

			return 0;

		}

		if (!this.widget.columns) {

			return 0;

		}

		return this.widget.columns.length;

	}

	//==============================
	// Table Title
	//==============================
	get tableTitle() {

		if (this.widget) {

			return this.widget.title;

		}

		return '';

	}

	//==============================
	// Total Records
	//==============================
	get totalRows() {

		if (!this.hasData) {

			return 0;

		}

		return this.widget.rows.length;

	}

	//==============================
	// Refresh Method
	//==============================
	@api
	refresh(widget) {

		this.widget = widget;

	}

	//==========================================================
	// Search Records
	// Returns filtered rows
	//==========================================================
	search(searchText) {

		if (!this.hasData) {

			return [];

		}

		if (!searchText) {

			return this.tableRows;

		}

		const value = searchText.toLowerCase();

		return this.tableRows.filter(row => {

			return row.cells.some(cell => {

				return String(cell.value)
					.toLowerCase()
					.includes(value);

			});

		});

	}

	//==========================================================
	// Sort Records
	// columnIndex = 0,1,2...
	// direction = asc / desc
	//==========================================================
	sort(columnIndex, direction = 'asc') {

		if (!this.hasData) {

			return [];

		}

		let rows = [...this.tableRows];

		rows.sort((a, b) => {

			let valueA = a.cells[columnIndex].value;
			let valueB = b.cells[columnIndex].value;

			valueA = String(valueA).toLowerCase();
			valueB = String(valueB).toLowerCase();

			if (direction === 'asc') {

				return valueA.localeCompare(valueB);

			}

			return valueB.localeCompare(valueA);

		});

		return rows;

	}

	//==========================================================
	// Risk Badge CSS
	//==========================================================
	getRiskClass(value) {

		if (!value) {

			return '';

		}

		const risk = value.toString().toLowerCase();

		if (risk === 'high') {

			return 'riskHigh';

		}

		if (risk === 'medium') {

			return 'riskMedium';

		}

		if (risk === 'low') {

			return 'riskLow';

		}

		return '';

	}

	//==========================================================
	// Format Currency
	//==========================================================
	formatCurrency(value) {

		if (value === null || value === undefined) {

			return '';

		}

		if (isNaN(value)) {

			return value;

		}

		return Number(value).toLocaleString(
			'en-US',
			{
				style: 'currency',
				currency: 'USD'
			}
		);

	}

	//==========================================================
	// Format Percentage
	//==========================================================
	formatPercent(value) {

		if (value === null || value === undefined) {

			return '';

		}

		if (isNaN(value)) {

			return value;

		}

		return value + '%';

	}

	//==========================================================
	// Row Click
	//==========================================================
	handleRowClick(event) {

		const rowId = event.currentTarget.dataset.id;

		const customEvent = new CustomEvent(

			'rowclick',

			{

				detail: {

					rowId: rowId

				}

			}

		);

		this.dispatchEvent(customEvent);

	}

	//==========================================================
	// Export Table Data
	//==========================================================
	@api
	exportData() {

		if (!this.hasData) {

			return [];

		}

		return JSON.parse(

			JSON.stringify(

				this.widget.rows

			)

		);

	}

	//==========================================================
	// Future Pagination Hook
	//==========================================================
	getPage(pageNumber, pageSize) {

		if (!this.hasData) {

			return [];

		}

		const start = (pageNumber - 1) * pageSize;

		return this.tableRows.slice(

			start,

			start + pageSize

		);

	}

	//==========================================================
	// Total Pages
	//==========================================================
	totalPages(pageSize) {

		if (!this.hasData) {

			return 0;

		}

		return Math.ceil(

			this.totalRows / pageSize

		);

	}
}