@isTest
private class TradesServiceTest {
    @isTest
    private static void getTrades_shouldReturnTrades() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TradeSelector tradeSelectorMock = (TradeSelector)mocks.mock(TradeSelector.class);
            
        Id tradeId = fflib_IDGenerator.generate(Trade__c.SObjectType);
        Trade__c trade = new Trade__c(
            Id = tradeId
        );
        Integer limitOf = 10;

        mocks.startStubbing();
		mocks.when(tradeSelectorMock.getData()).thenReturn(new List<Trade__c>{ trade });
		mocks.when(tradeSelectorMock.getOrderByCreatedDateDesc()).thenReturn(tradeSelectorMock);
		mocks.when(tradeSelectorMock.getWithLimit(limitOf)).thenReturn(tradeSelectorMock);
		mocks.stopStubbing();

        // When
        TradesService tradeSrv = new TradesService(tradeSelectorMock, new RestHttpRequester());
        List<Trade__c> trades = tradeSrv.getTrades(limitOf);
        // Then
        System.assertEquals(new List<Trade__c>{ trade }, trades);
    }
    
    @isTest
    private static void getLatestRates_shouldReturnRates() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        RestHttpRequester requesterMock = (RestHttpRequester)mocks.mock(RestHttpRequester.class);
            
        String baseCurrency = 'USD';
        List<String> currencies = new List<String>{ 'USD', 'BRL', 'EUR' };

        String responseBody = '{"success": true,"timestamp": 1653851464,"base": "USD", "date": "2022-05-29", "rates": { "USD": 1, "EUR": 0.931505,"BRL": 4.731022}}';
        String namedCredentialPath = String.format(TradesService.LATEST_RATE_PATH, new List<Object>{ String.join(currencies, ','), baseCurrency });
        Map<String, String> mapHeader =  new Map<String, String>{ 'apikey' => TradesService.LATEST_RATE_CREDENTIAL };
        HTTPResponse response = new HTTPResponse();
        response.setStatusCode(200);
        response.setBody(responseBody);

        mocks.startStubbing();
		mocks.when(requesterMock.send(
            'GET', namedCredentialPath, null, mapHeader
        )).thenReturn(response);
		mocks.stopStubbing();

        // When
        TradesService tradeSrv = new TradesService(new TradeSelector(), requesterMock);
        TradesService.LatestRatesForCurrency ratesForCurrency = tradeSrv.getLatestRates(baseCurrency, currencies);
        // Then
        TradesService.LatestRatesForCurrency expectedRatesForCurrency = new TradesService.LatestRatesForCurrency(responseBody);
        System.assertEquals(expectedRatesForCurrency.baseCurrency, ratesForCurrency.baseCurrency);
        System.assertEquals(expectedRatesForCurrency.rates.size(), ratesForCurrency.rates.size());
    }
    
    @isTest
    private static void getLatestRates_invalidCodeReturn_shouldThrowException() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        RestHttpRequester requesterMock = (RestHttpRequester)mocks.mock(RestHttpRequester.class);
            
        String baseCurrency = 'USD';
        List<String> currencies = new List<String>{ 'USD', 'BRL', 'EUR' };

        String responseBody = '{"success": true,"timestamp": 1653851464,"base": "USD", "date": "2022-05-29", "rates": { "USD": 1, "EUR": 0.931505,"BRL": 4.731022}}';
        String namedCredentialPath = String.format(TradesService.LATEST_RATE_PATH, new List<Object>{ String.join(currencies, ','), baseCurrency });
        Map<String, String> mapHeader =  new Map<String, String>{ 'apikey' => TradesService.LATEST_RATE_CREDENTIAL };
        HTTPResponse response = new HTTPResponse();
        response.setStatusCode(500);

        mocks.startStubbing();
		mocks.when(requesterMock.send(
            'GET', namedCredentialPath, null, mapHeader
        )).thenReturn(response);
		mocks.stopStubbing();

        // When
        TradesService tradeSrv = new TradesService(new TradeSelector(), requesterMock);
        String exceptionMsg;
        try {
            TradesService.LatestRatesForCurrency ratesForCurrency = tradeSrv.getLatestRates(baseCurrency, currencies);
        }
        catch(Exception ex) {
            exceptionMsg = ex.getMessage();
        }
        //then
        System.assertEquals('Error retrieving latest trades', exceptionMsg);
    }
    
    @isTest
    private static void getLatestRates_nullBaseCurrency_shouldThrowException() {
        TradesService service = new TradesService();
        List<String> currencies = new List<String>{ 'USD', 'BRL', 'EUR' };
        String exceptionMsg;
        try {
            service.getLatestRates(null, currencies);
        }
        catch(Exception ex) {
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals('Base currency not provided.', exceptionMsg);
    }
    
    @isTest
    private static void getLatestRates_nullCurrencies_shouldThrowException() {
        TradesService service = new TradesService();
        String exceptionMsg;
        try {
            service.getLatestRates('USD', null);
        }
        catch(Exception ex) {
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals('Currencies not provided.', exceptionMsg);
    }
    
    @isTest
    private static void submitNewTradeEvent_emptyIdsList_shouldThrowException() {
        TradesService service = new TradesService();
        String exceptionMsg;
        try {
            service.submitNewTradeEvent(new List<Id>());
        }
        catch(Exception ex) {
            exceptionMsg = ex.getMessage();
        }
        System.assertEquals('Trade Ids not provided to dispatch event.', exceptionMsg);
    }
}