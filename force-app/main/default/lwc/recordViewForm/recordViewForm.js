import { LightningElement } from 'lwc';
import { NavigationMixin  } from 'lightning/navigation';
import { ShowToastEvent   } from 'lightning/platformShowToastEvent';

import ACCOUNT  from '@salesforce/schema/Account';
import NAME     from '@salesforce/schema/Account.Name';
import STREET   from '@salesforce/schema/Account.BillingStreet';
import CITY     from '@salesforce/schema/Account.BillingCity';
import STATE    from '@salesforce/schema/Account.BillingState';
import ZIP      from '@salesforce/schema/Account.BillingPostalCode';
import COUNTRY  from '@salesforce/schema/Account.BillingCountry';
import WEBSITE  from '@salesforce/schema/Account.Website';
import PHONE    from '@salesforce/schema/Account.Phone';
import SIC      from '@salesforce/schema/Account.Sic';
import DBNUMBER from '@salesforce/schema/Account.DunsNumber';
import DBNAME   from '@salesforce/schema/Account.DandbCompany.Name';

const FIELDS = {
        name: NAME,
      street: STREET,
        city: CITY,
       state: STATE,
         zip: ZIP,
     country: COUNTRY,
       phone: PHONE,
     website: WEBSITE,
         sic: SIC,
    dbNumber: DBNUMBER,
      dbName: DBNAME
};

export default class RecordViewForm extends NavigationMixin(LightningElement) {
    objectApiName;
    recordId;
    fields;

    constructor() {
        super();
        this.objectApiName = ACCOUNT;
        this.recordId = '001fj00000ea8jeAAA';
        this.fields = FIELDS;
    }

    handleClick(event) {
        console.clear();
        switch (event.target.label) {
            case 'Home':
                this.gotoPage(this.homePageRef());
                break;
            case 'LWC Fundamentals':
                this.gotoPage(this.navItemPageRef('LWC_Fundamentals'));
                break;
            case 'Datatables':
                this.gotoPage(this.navItemPageRef('Datatables'));
                break;
            case 'Picklists':
                this.gotoPage(this.navItemPageRef('Picklists'));
                break;
            default:
                console.warn(event);
        }
    }

    gotoPage(pageRef) {
        this[NavigationMixin.GenerateUrl](pageRef)
       .then(
            (url) => {
                console.info(url);
            }
        )
       .catch(
            (error) => {
                this.showToast('Error generating url!', error.body.message, 'error', 'pester');
                console.error(error);
            }
        );
        try {
            this[NavigationMixin.Navigate](pageRef);
        }
        catch(error) {
            this.showToast('Error navigating to page!', error.body.message, 'error', 'pester');
            console.error(error);
        }
    }

    homePageRef() {
        return {
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        };
    }

    navItemPageRef(pageApiName) {
        return {
            type: 'standard__navItemPage',
            attributes: {
                apiName: pageApiName
            }
        };
    }

    get text() {
        return (`
Use the lightning-record-view-form component to create a form that displays Salesforce record data for specified fields associated with that record. The fields are rendered with their labels and current values as read-only.

You can customize the form layout or provide custom rendering of record data. If you don't require customizations, use lightning-record-form instead.

To specify read-only fields, use lightning-output-field components inside lightning-record-view-form.`);
    }

    showToast(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({
              title: title,
            message: message,
            variant: (variant || 'info'        ),
               mode: (mode    || 'disnmissible')
        }));
    }
}