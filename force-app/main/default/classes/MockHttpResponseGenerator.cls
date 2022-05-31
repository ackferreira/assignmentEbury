@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{}');
        return res;
    }
}