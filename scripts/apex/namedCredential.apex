/*
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:Infinitus/benefit-verification-request');
req.setMethod('POST');
req.setHeader('Content-Type', 'application/json');
req.setBody('{ key: "value" }');
HttpResponse res = new Http().send(req);
if (res.getStatusCode() == 200) {
    InfinitusHttpResponseWrapper wrapper = InfinitusHttpResponseWrapper.parse(res.getBody());
    System.debug(LoggingLevel.INFO, wrapper);
}
else {
    System.debug(Logginglevel.ERROR, res.getStatusCode());
}
*/
ServiceDetail__c sd = [SELECT Id, Name, Status__c FROM ServiceDetail__c WHERE Status__c != 'Pending' LIMIT 1];
sd.Status__c = 'Pending';
for (Database.SaveResult sr : Database.update(new List<ServiceDetail__c>{ sd}, false)) {
    if (!sr.isSuccess()) {
        for (Database.Error e : sr.getErrors()) {
            System.debug(LoggingLevel.ERROR, e.getStatusCode() + ': ' + e.getMessage());
        }
        throw new DMLException(System.Label.ERROR_UPDATING_CARE_BENEFIT_VERIFY_REQUEST_RECORD);
    }
}