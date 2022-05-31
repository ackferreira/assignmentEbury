public with sharing class TradesService {
    private String LATEST_RATE_CREDENTIAL = '5IAvTHrI45AxOzRrUSLckZGrAO6Ne2F7';
    private String LATEST_RATE_PATH       = 'FixerAPI/latest?symbols={0}&base={1}';
    private Integer DEFAULT_LIMIT         = 10;

    private TradeSelector tradeSelector;

    public TradesService() {
        this(new TradeSelector());
    }

    public TradesService(TradeSelector tradeSelector) {
        this.tradeSelector = tradeSelector;
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

        DateTime start = System.Now();
        while(System.Now().getTime()< start.getTime()+800){}

        switch on baseCurrency {
            when 'USD' {
                return new LatestRatesForCurrency('{"success": true,"timestamp": 1653851464,"base": "USD", "date": "2022-05-29", "rates": { "USD": 1, "EUR": 0.931505,"BRL": 4.731022}}');
            }
            when 'EUR' {
                return new LatestRatesForCurrency('{"success": true,"timestamp": 1653851535,"base": "EUR","date": "2022-05-29","rates": {"USD": 1.073532, "EUR": 1,"BRL": 5.078864}}');
            }
            when 'BRL' {
                return new LatestRatesForCurrency('{"success": true, "timestamp": 1653851583,"base": "BRL", "date": "2022-05-29", "rates": {"USD": 0.211371, "EUR": 0.196893, "BRL": 1}}');
            }
            when else {
                throw new TradesServiceException('Error retrieving latest trades');
            }
        }

/*
        HTTPResponse res = RestHttpRequester.send('GET', namedCredentialPath, null, mapHeader);
        String s = res.getBody();
        system.debug('res.getBody()>>>>>>>>>>>>>>>>>>>>>>');
        system.debug(s);

        if (res.getStatusCode() == 200) {
            return new LatestRatesForCurrency(res.getBody());
        }
        throw new TradesServiceException('Error retrieving latest trades');*/
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
