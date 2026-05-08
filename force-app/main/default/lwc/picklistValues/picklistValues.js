import { LightningElement, api, wire      } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin                  } from 'lightning/navigation';
import { ShowToastEvent                   } from 'lightning/platformShowToastEvent';
import { refreshApex                      } from '@salesforce/apex';

import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_STATUS from '@salesforce/schema/Case.Status';

export default class PicklistValues extends NavigationMixin(LightningElement) {
    _wiredResponse;
    picklistValues;

    pageRef = {
        type: 'standard__recordPage',
        attributes: {
            objectApiName: CASE_OBJECT,
                 recordId: '500fj00001ABmSrAAL',
               actionName: 'view'
        }
    };

    constructor() {
        super();
    }

    connectedCallback() {
        console.clear();
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectInfo;

    @wire(getPicklistValues, { recordTypeId: "$caseObjectInfo.data.defaultRecordTypeId", fieldApiName: CASE_STATUS })
    handle(response) {
        this._wiredResponse   = response;
        const { error, data } = response;
        if (error) {
            picklistValues = undefined;
            this.showToast('Error retrieving picklist values!', error.body.message, 'error', 'pester');
            console.error(error);
        }
        else if (data) {
            this.picklistValues = JSON.stringify(data.values, null, 2);
            console.info(data);
        }
    }

    handleClick(event) {
        console.clear();
        switch (event.target.label) {
            case 'Go To Case Record':
                this.gotoPage(this.pageRef);
                break;
            case 'Show Toast':
                this.showToast('Good Job!', 'You clicked the "Show Toast" button.');
                break;
            default:
                console.warn(event);
        }
    }

    gotoPage(pageRef) {
        this[NavigationMixin.GenerateUrl](pageRef)
       .then(
            (url) => {
                console.info('url:', url);
            }
        )
       .catch(
            (error) => {
                this.showToast('Error generating record page url!', error.body.message, 'error', 'pester');
                console.error(error);
            }
        );
        try {
            this[NavigationMixin.Navigate](this.pageRef);
        }
        catch(error) {
            this.showToast('Error navigating to record page!', error.body.message, 'error', 'pester');
            console.error(error);
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