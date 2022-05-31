public with sharing class TradesViewController {

    @AuraEnabled(cacheable=true)
    public static List<Trade__c> getTrades(Integer limitOf) {
        TradesService tradeService = new TradesService();
        return tradeService.getTrades(limitOf);
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Rate> getRates(String baseCurrency) {
        TradesService tradeService = new TradesService();
        //get currencies values
        TradesService.LatestRatesForCurrency latestRates = tradeService.getLatestRates(
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
        TradesService tradeService = new TradesService();
        return tradeService.submitNewTradeEvent(tradeId);
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
