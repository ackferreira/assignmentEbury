@isTest
private class TradesViewControllerTest {
    @isTest
    private static void getTrades_shouldReturnTrades() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TradesService tradeSrvMock  = (TradesService)mocks.mock(TradesService.class);

        Id tradeId = fflib_IDGenerator.generate(Trade__c.SObjectType);
        Trade__c trade = new Trade__c(
            Id = tradeId
        );
        Integer limitOf = 10;

        mocks.startStubbing();
		mocks.when(tradeSrvMock.getTrades(limitOf)).thenReturn(new List<Trade__c>{ trade });
		mocks.stopStubbing();

        // When
        TradesViewController.tradeService = tradeSrvMock;
        List<Trade__c> trades = TradesViewController.getTrades(limitOf);
        // Then
        System.assertEquals(new List<Trade__c>{ trade }, trades);
    }

    @isTest
    private static void getRates_shouldReturnTrades() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TradesService tradeSrvMock  = (TradesService)mocks.mock(TradesService.class);
            
        String baseCurrency = 'USD';
        TradesService.LatestRatesForCurrency latestRateCurr =  new TradesService.LatestRatesForCurrency(
            '{"success": true,"timestamp": 1653851464,"base": "USD", "date": "2022-05-29", "rates": { "USD": 1, "EUR": 0.931505,"BRL": 4.731022}}'
        );
        List<TradesViewController.Rate> rates = new List<TradesViewController.Rate>();
        for (TradesService.Rate rateCurr : latestRateCurr.rates) {
            rates.add(new TradesViewController.Rate(rateCurr.currencyName, rateCurr.rate));
        }

        mocks.startStubbing();
		mocks.when(tradeSrvMock.getLatestRates(
            baseCurrency, 
            SObjectUtils.getPicklistValuesList('Trade__c', 'BuyCurrency__c')
        )).thenReturn(latestRateCurr);
		mocks.stopStubbing();

        // When
        TradesViewController.tradeService = tradeSrvMock;
        List<TradesViewController.Rate> ratesFromController = TradesViewController.getRates(baseCurrency);
        // Then
        System.assertEquals(rates.size(), ratesFromController.size());
    }

    @isTest
    private static void publishTradeEvent_shouldReturnString() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        TradesService tradeSrvMock  = (TradesService)mocks.mock(TradesService.class);
            
        Id tradeId = fflib_IDGenerator.generate(Trade__c.SObjectType);

        mocks.startStubbing();
		mocks.when(tradeSrvMock.submitNewTradeEvent(tradeId)).thenReturn('eventId');
		mocks.stopStubbing();

        // When
        TradesViewController.tradeService = tradeSrvMock;
        String eventIdFromController = TradesViewController.publishTradeEvent(tradeId);
        // Then
        System.assertEquals('eventId', eventIdFromController);
    }
}