public with sharing class MultiCurrencyBatchHelper {

    private static final String API_KEY = 'fca_live_V5x30uBAg7REgeJDpyOFTpmfJku2sO4Q67poli46';
    public static void updateCurrencyRates(List<CurrencyType> currencyList){
        try{
            List<DatedConversionRateClass> datedConversionRateList = new List<DatedConversionRateClass>();
            List<String> baseCurrencyList = new List<String>();
            List<String> currenciesList = new List<String>();
            Map<String, Object> data = new Map<String, Object>();
            Map<String, Object> jsonMap = new Map<String, Object>();

            Date today = Date.today();
            // Convert Date to DateTime
            DateTime dateTimeObj = DateTime.newInstance(today.year(), today.month(), today.day());
            // Format DateTime to String
            String formattedDate = dateTimeObj.format('yyyy-MM-dd');

            for(CurrencyType currencyType : currencyList){
                if(currencyType.IsCorporate){
                baseCurrencyList.add(currencyType.IsoCode);
                }
                else{
                currenciesList.add(currencyType.IsoCode);
                }
            }
            Map<String, String> queryParams = new Map<String, String>{
                'apikey' => API_KEY,
                'currencies' => String.join(currenciesList , ','),
                'base_currency' => String.join(baseCurrencyList , ',')
            };
            
            String baseUrl = 'https://api.freecurrencyapi.com/v1/latest';
           
            // Construct the URL with query parameters
            String urlWithParams = baseUrl + '?';
            List<String> paramList = new List<String>();
            for (String key : queryParams.keySet()) {
                paramList.add(key + '=' + EncodingUtil.urlEncode(queryParams.get(key), 'UTF-8'));
            }
            urlWithParams += String.join(paramList, '&');
                        
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(urlWithParams);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('GET');
            if (!Test.isRunningTest()) {      
                res = http.send(req);
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                    Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    System.debug(response);
                    
                    for(Object obj : response.values()){
                        data = ( Map<String, Object>) obj;
                        System.debug(data);
                    }
                    for(String key : data.keySet()){
                        System.debug(key);
                        System.debug((Decimal) data.get(key));
                        datedConversionRateList.add(new DatedConversionRateClass(key, (Decimal) data.get(key), formattedDate));
                    } 
                    
                    jsonMap.put('allOrNone', 'true');
                    jsonMap.put('records', datedConversionRateList);
                    
                    HttpRequest conversionRateRequest = new HttpRequest();
                    HttpResponse conversionRateResponse = new HttpResponse();
                    conversionRateRequest.setEndpoint(URL.getOrgDomainURL().toExternalForm() + '/services/data/v58.0/composite/sObjects');
                    conversionRateRequest.setHeader('Content-Type', 'application/json');
                    conversionRateRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                    conversionRateRequest.setMethod('POST');
                    conversionRateRequest.setBody(JSON.serialize(jsonMap));
                    conversionRateResponse = http.send(conversionRateRequest);


            }

            }
        }catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }              

    }

    public class DatedConversionRateClass {
        public Map<String, String> attributes;
        public String isoCode;
        public Decimal conversionRate;
        public String startDate;
        
        public DatedConversionRateClass(String isoCode, Decimal conversionRate, String startDate) {
            this.attributes = new Map<String, String>();
            this.attributes.put('type', 'DatedConversionRate');
            this.isoCode = isoCode;
            this.conversionRate = conversionRate.setScale(2, RoundingMode.CEILING);
            this.startDate = startDate;
        }
    }
    
}