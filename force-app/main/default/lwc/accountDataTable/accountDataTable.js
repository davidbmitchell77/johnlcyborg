import { LightningElement, wire, track } from 'lwc';

import getAccounts from '@salesforce/apex/AccountsController.getAccounts';

export default class AccountDataTable extends LightningElement {
    @track accounts;
    @track columns = [
        { label: 'Name',           fieldName: 'Name',          type: 'text' ,    sortable: true },
        { label: 'Industry',       fieldName: 'Industry',      type: 'text',     sortable: true },
        { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency', sortable: true },
        { type:  'action',         typeAttributes: { rowActions: this.getRowActions }           }
    ];
    @track sortedBy;
    @track sortedDirection = 'asc';

    _wireData;
    error;

    @wire(getAccounts)
    handle(response) {
        const { data, error } = response;
        if (error) {
            this.error = error;
            this._wireData = undefined;
            this.accounts = undefined;
            console.error('Error fetching accounts:', error);
        }
        else if (data) {
            this._wireData = response;
            this.accounts = data;
            this.error = undefined;
            console.info(data);
        }
    }

    getRowActions(row, doneCallback) {
        const actions = [
            { label: 'View',   name: 'view'   },
            { label: 'Delete', name: 'delete' }
        ];
        doneCallback(actions);
    }

    /*
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view') {
            this.viewAccount(row);
        } else if (actionName === 'delete') {
            this.deleteAccount(row);
        }
    }
    */

    handleRowAction(event) {
        switch (event.detail.action.name) {
            case 'delete':
                this.deleteAccount(event.detail.row);
                break;
            case 'view':
                this.viewAccount(event.detail.row);
                break;
        }
    }

    deleteAccount(row) {
        console.log('Delete account:', row.Id);
      //implement delete logic (e.g., call Apex method)
    }

    viewAccount(row) {
        console.log('View account:', row.Id);
      //implement navigate to detail page
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
        this.sortData(sortedBy, sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.accounts));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = ((direction === 'asc') ? 1 : -1);
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // Handle undefined values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.accounts = parseData;
    }
}