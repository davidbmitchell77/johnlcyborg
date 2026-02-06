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



System.debug(LoggingLevel.INFO, System.JSON.serializePretty(new InfinitusHttpRequestWrapper()));