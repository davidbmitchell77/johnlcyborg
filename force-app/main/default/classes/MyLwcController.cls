public with sharing class MyLwcController {
    @AuraEnabled(cacheable=true)
    public static String callout01() {
        String response = '';
        CareBenefitVerifyRequest__c cbvr = [SELECT Id, Name, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c LIMIT 1];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Infinitus/benefit-verification-request');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(System.JSON.serialize(cbvr));
        req.setTimeout(3000);
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            response = res.getBody();
        }
        else {
            throw new AuraHandledException('HTTP ' + res.getStatusCode() + ': Callout failed.');
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static String callout02() {
        String response = '';
        CareBenefitVerifyRequest__c cbvr = [SELECT Id, Name, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c LIMIT 1];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Infinitus/benefit-verification-request');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(System.JSON.serialize(cbvr));
        req.setTimeout(3000);
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            response = res.getBody();
        }
        else {
            throw new AuraHandledException('HTTP ' + res.getStatusCode() + ': Callout failed.');
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static String callout03() {
        String response = '';
        CareBenefitVerifyRequest__c cbvr = [SELECT Id, Name, Status__c, StatusReason__c FROM CareBenefitVerifyRequest__c LIMIT 1];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Infinitus/benefit-verification-request');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(System.JSON.serialize(cbvr));
        req.setTimeout(3000);
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            response = res.getBody();
        }
        else {
            throw new AuraHandledException('HTTP ' + res.getStatusCode() + ': Callout failed.');
        }
        return response;
    }
}