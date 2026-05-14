import { LightningElement } from 'lwc';
import { NavigationMixin  } from 'lightning/navigation';
import { ShowToastEvent   } from 'lightning/platformShowToastEvent';

import OPPORTUNITY      from '@salesforce/schema/Opportunity';
import NAME             from '@salesforce/schema/Opportunity.Name';
import STAGE_NAME       from '@salesforce/schema/Opportunity.StageName';
import EXPECTED_REVENUE from '@salesforce/schema/Opportunity.ExpectedRevenue';
import PROBABILITY      from '@salesforce/schema/Opportunity.Probability';
import SOURCE           from '@salesforce/schema/Opportunity.LeadSource';
import TYPE             from '@salesforce/schema/Opportunity.Type';
import DESCRIPTION      from '@salesforce/schema/Opportunity.Description';
import NEXT_STEP        from '@salesforce/schema/Opportunity.NextStep';

const FIELDS = [
    NAME,
    STAGE_NAME,
    EXPECTED_REVENUE,
    PROBABILITY,
    SOURCE,
    TYPE,
    DESCRIPTION,
    NEXT_STEP
];

export default class LightningRecordForm extends NavigationMixin(LightningElement) {
    objectApiName;
    recordId;
    fields;
    options;
    value;
    layoutType;
    value;

    constructor() {
        super();
        this.objectApiName = OPPORTUNITY;
        this.recordId = '006fj000008e5etAAA';
        this.fields = FIELDS;
        this.layoutType = 'Compact';
        this.value = this.layoutType;
        this.options = [
            { label: 'Full',    value: 'Full'    },
            { label: 'Compact', value: 'Compact' },
            { label: 'Custom',  value: 'Custom'  }
        ];
    }

    handleChange(event) {
        this.layoutType = event.detail.value;
        console.info(event);
    }

    handleSubmit(event) {
        this.showToast('Record Submitted!', 'Your changes have been submitted.');
        console.info(event);
    }

    handleSuccess(event) {
        this.showToast('Success!', `Opportunity record ${this.recordId} was successfully updated.`, 'success', 'pester');
        console.info(event);
    }

    showToast(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({
              title: title,
            message: message,
            variant: (variant || 'info'       ),
               mode: (mode    || 'dismissible')
        }));
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

    get isCompact() {
        return (this.layoutType == 'Compact');
    }

    get isCustom() {
        return (this.layoutType == 'Custom');
    }

    get isFull() {
        return (this.layoutType == 'Full');
    }

    get text() {
        return (`Use the lightning-record-form component to quickly create forms to add, view, or update a record.

Using this component to create record forms is easier than building forms manually with lightning-record-edit-form or lightning-record-view-form. The lightning-record-form component provides these helpful features:

Switches between view and edit modes automatically when the user begins editing a field in a view form
Provides Cancel and Save buttons automatically in edit forms
Uses the object's default record layout with support for multiple columns
Loads all fields in the object's compact or full layout, or only the fields you specify.  It cannot display fields related to another (lookup) object.

However, lightning-record-form is less customizable. To customize the form layout or provide custom rendering of record data, use lightning-record-edit-form (add or update a record) and lightning-record-view-form (view a record).
        `);
    }
}