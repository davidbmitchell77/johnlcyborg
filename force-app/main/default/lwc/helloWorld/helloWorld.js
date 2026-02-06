import { LightningElement, api, track, wire } from 'lwc';

export default class HelloWorld extends LightningElement {
    fullName = "Zero to Hero";
    title = "Salesforce Developer";
    num1 = 0;

    @track address = {
            city: 'Chula Vista',
           state: 'California',
      postalCode: '91913',
         country: 'US'
    };

    getName() {
        return ("Hello, " + this.fullName + "!");
    }

    changeHandler(event) {
        console.info(event.target);
        this.title = event.target.value;
    }

    trackHandler(event) {
        console.clear();
        console.info(event.target.label);
        this.address = { ...this.address, city: event.target.value };
    }

    calculatorHandler(event) {
        console.clear();
        console.info(event.target);
        this.num1 = event.target.value;
    }

    get total() {
        return (this.num1 * 100);
    }
}