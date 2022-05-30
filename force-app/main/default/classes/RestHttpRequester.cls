public with sharing class RestHttpRequester {

    public static HTTPResponse send(String method, String namedCredential, String body, Map<String, String> mapHeader) {
        if (String.isBlank(method)) {
            throw new RequesterException('Method not provided');
        }
        if (String.isBlank(namedCredential)) {
            throw new RequesterException('Credential not provided');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + namedCredential);
        req.setMethod(method);

        if (mapHeader != null) {
            for (String headerKey : mapHeader.keySet()) {
                req.setHeader(headerKey, mapHeader.get(headerKey));
            }
        }
        if (String.isNotBlank(body)) {
            req.setBody(body);
        }

        return new Http().send(req);
    }

    public class RequesterException extends Exception {} 
}