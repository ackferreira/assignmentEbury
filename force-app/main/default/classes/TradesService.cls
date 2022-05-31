public with sharing class TradesService {
    @TestVisible
    private static String LATEST_RATE_CREDENTIAL = '5IAvTHrI45AxOzRrUSLckZGrAO6Ne2F7';
    @TestVisible
    private static String LATEST_RATE_PATH = 'FixerAPI/latest?symbols={0}&base={1}';
    private static Integer DEFAULT_LIMIT   = 10;

    private TradeSelector tradeSelector;
    private RestHttpRequester requester;

    public TradesService() {
        this(new TradeSelector(), new RestHttpRequester());
    }

    public TradesService(TradeSelector tradeSelector, RestHttpRequester requester) {
        this.tradeSelector = tradeSelector;
        this.requester = requester;
    }

    public List<Trade__c> getTrades(Integer limitOf) {
        Integer queryLimit = limitOf != null && limitOf >= 1 ? limitOf : DEFAULT_LIMIT;
        return tradeSelector.getOrderByCreatedDateDesc().getWithLimit(queryLimit).getData();
    }
    
    public String submitNewTradeEvent(ID tradeId) {
        return this.submitNewTradeEvent(new List<Id>{ tradeId });
    }

    public String submitNewTradeEvent(List<Id> tradeIds) {
        if (tradeIds == null || tradeIds.isEmpty()) {
            throw new TradesServiceException('Trade Ids not provided to dispatch event.');
        }
        NewTradeEvent__e newTradeEvent = new NewTradeEvent__e(
            EventBody__c = JSON.serialize(tradeIds)
        );

        Database.SaveResult eventResult = EventBus.publish(newTradeEvent);
        if (eventResult.isSuccess()) {
            return EventBus.getOperationId(eventResult);
        }
        throw new TradesServiceException('There was an error while publishing event.');
    }

    public LatestRatesForCurrency getLatestRates(String baseCurrency, List<String> currencies) {
        if (String.isBlank(baseCurrency)) {
            throw new TradesServiceException('Base currency not provided.');
        }
        if (currencies == NULL || currencies.isEmpty()) {
            throw new TradesServiceException('Currencies not provided.');
        }

        String namedCredentialPath = String.format(LATEST_RATE_PATH, new List<Object>{ String.join(currencies, ','), baseCurrency });
        Map<String, String> mapHeader =  new Map<String, String>{ 'apikey' => LATEST_RATE_CREDENTIAL };

        HTTPResponse res = requester.send('GET', namedCredentialPath, null, mapHeader);
        String s = res.getBody();

        if (res.getStatusCode() == 200) {
            return new LatestRatesForCurrency(res.getBody());
        }
        throw new TradesServiceException('Error retrieving latest trades');
    }

    public class LatestRatesForCurrency {
        public String baseCurrency;
        public Date rateDate;
        public List<Rate> rates;
        public String success;
        public String timestamp;

        public LatestRatesForCurrency(String bodyLatestRates) {
            Map<String, Object> latestRatesMap  = (Map<String, Object>)JSON.deserializeUntyped(bodyLatestRates);
            Map<String, Object> currenciesRates = (Map<String, Object>)latestRatesMap.get('rates');

            this.baseCurrency = (String)latestRatesMap.get('base');
            this.rateDate     = Date.valueOf((String)latestRatesMap.get('date'));

            for (String currencyName : currenciesRates.keySet()) {
                if (this.rates == null) {
                    this.rates = new List<Rate>();
                }
                this.rates.add(new Rate(currencyName, (Double)currenciesRates.get(currencyName)));
            }
        }
    }

    public class Rate {
        public String currencyName;
        public Double rate;

        public Rate(String currencyName, Double rate) {
            this.currencyName = currencyName;
            this.rate = rate;
        }
    }

    public class TradesServiceException extends Exception {} 
}
