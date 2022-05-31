@isTest
private class RestHttpRequesterTest {
    @isTest
    private static void send_shouldGetStatusCode() {
        // Given
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
        HTTPResponse response = new HTTPResponse();

        String namedCredential = 'test';
        String method = 'GET';
        Map<String, String> mapHeader = new Map<String, String>{ 'key' => 'value' };

        // When
        RestHttpRequester requester = new RestHttpRequester();
        HTTPResponse responseFromRequester = requester.send(method, namedCredential, '{}', mapHeader);
        // Then
        System.assertEquals(200, responseFromRequester.getStatusCode());
    }

    @isTest
    private static void send_noMethod_shouldThrowException() {
        RestHttpRequester requester = new RestHttpRequester();
        String exceptionMsg;
        try {
            HTTPResponse responseFromRequester = requester.send(null, 'named', '{}', new Map<String, String>());
        }
        catch(Exception ex) {
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals('Method not provided', exceptionMsg);
    }

    @isTest
    private static void send_noCredential_shouldThrowException() {
        RestHttpRequester requester = new RestHttpRequester();
        String exceptionMsg;
        try {
            HTTPResponse responseFromRequester = requester.send('GET', null, '{}', new Map<String, String>());
        }
        catch(Exception ex) {
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals('Credential not provided', exceptionMsg);
    }
}