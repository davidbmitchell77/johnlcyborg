import { LightningElement, api, track, wire } from 'lwc';
import { getRecord                          } from 'lightning/uiRecordApi';
import { ShowToastEvent                     } from 'lightning/platformShowToastEvent';
import { refreshApex                        } from '@salesforce/apex';

import getContacts from '@salesforce/apex/AccountsController.getContacts';
import callout01   from '@salesforce/apex/MyLwcController.callout01';
import callout02   from '@salesforce/apex/MyLwcController.callout02';
import callout03   from '@salesforce/apex/MyLwcController.callout03';
import LABEL       from '@salesforce/label/c.ErrorLabel';
import NAME        from '@salesforce/schema/Account.Name';
import PHONE       from '@salesforce/schema/Account.Phone';
import WEBSITE     from '@salesforce/schema/Account.Website';
import STREET      from '@salesforce/schema/Account.BillingStreet';
import CITY        from '@salesforce/schema/Account.BillingCity';
import STATE       from '@salesforce/schema/Account.BillingState';
import ZIP         from '@salesforce/schema/Account.BillingPostalCode';
import COUNTRY     from '@salesforce/schema/Account.BillingCountry';
import DBNAME      from '@salesforce/schema/Account.DandbCompany.Name';
import DBNUMBER    from '@salesforce/schema/Account.DunsNumber';

const FIELDS = [
    [ NAME, PHONE, WEBSITE, STREET, CITY, STATE, ZIP, COUNTRY ],
    [ DBNAME, DBNUMBER ]
];

export default class MyLightingWebComponent extends LightningElement {
    @api objectApiName;
    @api recordId;

    @api
    get parentProperty() {
        return this.childProperty;
    }

    set parentProperty(value) {
        this.childProperty = ((value > '') ? value.toUpperCase() : undefined);
    }

    account;
    contacts;
    wiredData;
    response01;
    response02;
    response03;
    childProperty;
    error;

    constructor() {
        super();
        this.objectApiName = 'Account';
        this.recordId      = '001fj00000ea8jdAAA';
        console.clear();
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS[0], optionalFields: FIELDS[1] })
    handle(response) {
        const { data, error } = response;
        if (error) {
            this.error     = error.body.message;
            this.wriedData = undefined;
            this.account   = undefined;
            this.showToast(LABEL, error.body.message, 'error', 'sticky');
            console.error(error);
        }
        else if (data) {
            this.account   = data;
            this.error     = undefined;
            this.wiredData = response;
            console.info(data);
        }
    }

    handleClick(event) {
        console.clear();
        switch (event.target.label) {
            case 'Account':
                this.refreshData();
                break;
            case 'Related Contacts':
                this.relatedContacts_await(this.recordId);
                this.relatedContacts_promise(this.recordId);
                break;
            case 'Run HTTP Requests':
                this.doCallouts_await();
                this.doCallouts_promise();
                break;
            case 'Clear':
                this.account    = undefined;
                this.contacts   = undefined;
                this.response01 = undefined;
                this.response02 = undefined;
                this.response03 = undefined;
                break;
        }
        console.info(`You clicked the ${event.target.label} button.`);
        this.showToast(`You clicked the ${event.target.label} button.`, '', 'warning');
    }

    async refreshData() {
        try {
            await refreshApex(this.wiredData);
            this.recordId   = '';
            this.recordId   = '001fj00000ea8jdAAA';
        }
        catch(error) {
            console.error(error);
        }
    }

    async relatedContacts_await(accountId) {
        try {
            await refreshApex(this.wiredData);
            const results = await getContacts({ accountId: accountId });
            this.contacts = JSON.stringify(results, null, 2);
            this.error    = undefined;
            this.showToast('relatedContacts_await:', 'It worked!');
            console.info('relatedContacts_await:');
            console.info(results);
        }
        catch(error) {
            this.error    = error.body.message;
            this.contacts = undefined;
            this.showToast(LABEL, error.body.message, 'error', 'sticky');
            console.error(error);
        }
    }

    relatedContacts_promise(accountId) {
       refreshApex(this.wiredData)
      .then(
           () => {
               const data = getContacts({ accountId: accountId })
               return data;
           }
       )
      .then(
           (data) => {
               this.contacts = JSON.stringify(data, null, 2);
               this.error    = undefined;
               console.info('relatedContacts_promise:');
               console.info(data);
               this.showToast('relatedContacts_promise:', 'It worked!');
           }
       )
      .catch(
           (error) => {
               this.error    = error;
               this.contacts = undefined;
               this.showToast(LABEL, error.body.message, 'error', 'sticky');
               console.info(error);
           }
       )
    }

    async doCallouts_await() {
        try {
            const [ response01, response02, response03 ] = await Promise.all([
                callout01(),
                callout02(),
                callout03()
            ]);
            this.response01 = response01;
            this.response02 = response02;
            this.response03 = response03;
            this.error      = undefined;
            console.info('doCallouts_await:');
            console.info(response01);
            console.info(response02);
            console.info(response03);
            this.showToast('doCallouts_await:', 'It worked!');
        }
        catch(error) {
            console.error(error);
            this.error      = error.body.message;
            this.response01 = undefined;
            this.response02 = undefined;
            this.response03 = undefined;
            this.showToast('Error during http request!', error.body.message, 'error', 'sticky');
        }
    }

    doCallouts_promise() {
        Promise.all([ callout01(), callout02(), callout03() ])
       .then(
            (responses) => {
                console.info('doCallouts_promise:');
                responses.map(
                    (response, i) => {
                        console.info(response);
                        if (i == 0) { this.response01 = response; } else
                        if (i == 1) { this.response02 = response; } else
                        if (i == 2) { this.response03 = response; }
                    }
                );
                this.error = undefined;
                this.showToast('doCallouts_promise:', 'It worked!');
            }
        )
       .catch(
            (error) => {
                console.error(error);
                this.error      = error.body.message;
                this.response01 = undefined;
                this.response02 = undefined;
                this.response03 = undefined;
                this.showToast('Error during http request!', error.body.message, 'error', 'sticky');
            }
        );
    }

    showToast(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({
              title: title,
            message: message,
            variant: (variant || 'info'  ),
               mode: (mode    || 'pester')
        }));
    }
}