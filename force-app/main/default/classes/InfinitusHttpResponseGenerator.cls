@isTest
global class InfinitusHttpResponseGenerator implements HttpCalloutMock {
    private final Integer statusCode;

    global InfinitusHttpResponseGenerator(Integer sc) {
        this.statusCode = sc;
    }

    global HTTPResponse respond(HTTPRequest request) {
        System.assertEquals('POST', request.getMethod());
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(jsonBody());
        response.setStatusCode(this.statusCode);
        return response;
    }

    private String jsonBody() {
        InfinitusHttpResponseWrapper wrapper = new InfinitusHttpResponseWrapper();
        wrapper.status       = this.statusCode == 200 ? 'Acknowledged' : 'Rejected';
        wrapper.statusReason = this.statusCode == 200 ? 'Acknowledged' : 'Bad request';
        return System.JSON.serializePretty(wrapper);
    }
}