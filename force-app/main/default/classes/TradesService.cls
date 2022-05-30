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

    public LatestRatesForCurrency getLatestRates(String baseCurrency, List<String> currencies) {
        if (String.isBlank(baseCurrency)) {
            throw new TradesServiceException('base Ccrrency not provided');
        }
        if (currencies == NULL || currencies.isEmpty()) {
            throw new TradesServiceException('currencies not provided');
        }

        String namedCredentialPath = String.format(LATEST_RATE_PATH, new List<Object>{ String.join(currencies, ','), baseCurrency });
        Map<String, String> mapHeader =  new Map<String, String>{ 'apikey' => LATEST_RATE_CREDENTIAL };

        HTTPResponse res = RestHttpRequester.send('GET', namedCredentialPath, null, mapHeader);
        String s = res.getBody();
        system.debug('res.getBody()>>>>>>>>>>>>>>>>>>>>>>');
        system.debug(s);

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
