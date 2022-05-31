public with sharing class TradesViewController {
    @testVisible
    private static TradesService tradeService;

    private static TradesService getTradeService() {
        if (tradeService == null) {
            tradeService = new TradesService();
        }
        return tradeService;
    }

    @AuraEnabled(cacheable=true)
    public static List<Trade__c> getTrades(Integer limitOf) {
        return getTradeService().getTrades(limitOf);
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Rate> getRates(String baseCurrency) {
        //get currencies values
        TradesService.LatestRatesForCurrency latestRates = getTradeService().getLatestRates(
            baseCurrency, 
            SObjectUtils.getPicklistValuesList('Trade__c', 'BuyCurrency__c')
        );

        List<Rate> rates = new List<Rate>();
        for (TradesService.Rate rateCurr : latestRates.rates) {
            rates.add(new Rate(rateCurr.currencyName, rateCurr.rate));
        }
        return rates;
    }

    @AuraEnabled(cacheable=false)
    public static String publishTradeEvent(Id tradeId) {
        return getTradeService().submitNewTradeEvent(tradeId);
    }

    public class Rate {
        @AuraEnabled
        public String toCurrency;
        @AuraEnabled
        public Double value; 

        public Rate(String toCurrency, Double value) {
            this.toCurrency = toCurrency;
            this.value      = value;
        }
    }
}
