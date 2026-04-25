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

    account;
    response01;
    response02;
    response03;
    error;

    constructor() {
        super();
        this.objectApiName = 'Account';
        this.recordId      = '001fj00000ea8jdAAA';
        console.clear();
    }

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS[0], optionalFields: FIELDS[1] })
    handleResponse({ error, data }) {
        if (error) {
            this.error   = error.body.message;
            this.account = undefined;
            this.showToast(LABEL, error.body.message, 'error');
            console.error(error);
        }
        else if (data) {
            this.account = data;
            this.error   = undefined;
            console.info(data);
        }
    }

    handleClick(event) {
        console.clear();
        switch (event.target.label) {
            case 'Related Contacts':
                this.relatedContacts_async(this.recordId);
                this.relatedContacts_promise(this.recordId);
                break;
            case 'Run HTTP Requests':
                this.doCallouts_await();
                this.showToast('Button clicked!', `You clicked the ${event.target.label} button.`);
                break;
            default:
                this.showToast('Button clicked!', `You clicked the ${event.target.label} button.`);
                console.info(`You clicked the ${event.target.label} button.`);
        }
    }

    async relatedContacts_async(accountId) {
        try {
            await refreshApex(this.account);
            const results = await getContacts({ 'accountId': accountId });
            this.contacts = { ...results };
            this.error    = undefined;
            this.showToast('relatedContacts_async:', 'It worked!');
            console.info('relatedContacts_async:');
            console.info(results);
        }
        catch(e) {
            this.error = e.body.message;
            this.contacts = undefined;
            this.showToast(LABEL, this.error, 'error', 'sticky');
            console.error(e);
        }
    }

    relatedContacts_promise(accountId) {
        refreshApex(this.account);
        getContacts({ accountId: accountId })
       .then(
            (results) => {
                this.contacts = { ...results };
                this.error = undefined;
                console.info('relatedContacts_promise:');
                console.info(results);
                this.showToast('relatedContacts_promise', 'It worked!');
            }
        )
       .catch(
            (e) => {
                this.error = { ...e };
                this.contacts = undefined;
                this.showToast(LABEL, this.error, 'error', 'pester');
                console.info(e);
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
            console.info(response01);
            console.info(response02);
            console.info(response03);
        }
        catch(error) {
            console.error(error);
            this.error = error.body.message;
            this.response01 = undefined;
            this.response02 = undefined;
            this.response03 = undefined;
            this.showToast('Error during http request!', error.body.message, 'error', 'pester');
        }
    }

    showToast(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({
              title: title,
            message: message,
            variant: (variant || 'info'       ),
               mode: (mode    || 'dismissible')
        }));
    }
}