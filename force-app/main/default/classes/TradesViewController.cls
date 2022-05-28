public with sharing class TradesViewController {
    @AuraEnabled(cacheable=true)
    public static List<Trade__c> getTrades(Integer limitOf) {
        TradesService tradeService = new TradesService();
        return tradeService.getTrades(limitOf);
    }
}
