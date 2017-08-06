public with sharing class AddressFinderApexController {
    
    @AuraEnabled
    public static String getConfigKey() {
        List<Config__C> configs = Config__C.getAll().values();
        return (configs != null && configs.size() > 0 ? configs[0].Key__c : null);
    }
    
    @AuraEnabled
    public static String getConfigCountryCode() {
        List<Config__C> configs = Config__C.getall().values();
        return (configs != null && configs.size() > 0 ? configs[0].Country_Code__c : null);
    }
    
    @AuraEnabled
    public static String getAppVersion() {
        Version version = System.requestVersion();
        return (version == null ? 'unknown' : version.major() + '.' + version.minor());
    }
    
    @AuraEnabled
    public static Map<String, Object> fetchRecordAddresses(Id recordId, Boolean aggregated) {
      String objectName = recordId.getSobjectType().getDescribe().getName();
      Sobject rec = fetchRecordObject(recordId, aggregated);
      Map<String, Object> addresses = new Map<String, Object>();
      List<String> fieldsToShow = getFieldsToShow(objectName, aggregated);
      if(rec != null && fieldsToShow.size() > 0) {
        for(String field: fieldsToShow) {
          addresses.put(field, rec.get(field));
        }
      }
      return addresses;
    }
    
    public static Sobject fetchRecordObject(Id recordId, Boolean aggregated) {
      if(recordId != null) {
        String objectName = recordId.getSobjectType().getDescribe().getName();
        List<String> fieldsToShow = getFieldsToShow(objectName, aggregated);
        if(fieldsToShow.size() > 0) {
          return queryForRecord(recordId, String.join(fieldsToShow, ', '), objectName);
        }
      }
      return null;
    }
    
    public static List<String> getFieldsToShow(String objectName, Boolean aggregated) {
      String[] prefixes = getPrefixTypesForObject(objectName);
      List<String> fieldsToShow = new List<String>();
      for(String prefix: prefixes) {
        for(String suffix: getSuffixes(aggregated)) {
          String caseSuffix = (String.isEmpty(prefix) ? suffix : suffix.capitalize());
          fieldsToShow.add(prefix + caseSuffix);
        }
      }
      return fieldsToShow;
    }
    
    private static Sobject queryForRecord(Id recordId, String fieldsToShow, String objectName) {
      String soql = 'Select ' + fieldsToShow + ' from ' + objectName + ' where Id = :recordId';
      Sobject rec = Database.query(soql);
      return (rec == null ? recordId.getSobjectType().newSObject() : rec);
    }
    
    private static String[] getSuffixes(Boolean aggregated) {
      return (aggregated ? new String[]{'Address'} : new String[]{'street', 'city', 'state', 'postalCode', 'country'});
    }
    
    @AuraEnabled
    public static List<String> getAddressTypesForRecord(Id recordId) {
      List<String> addressTypes = new List<String>();
      for(String prefix: getPrefixTypesForObject(recordId.getSobjectType().getDescribe().getName())) {
        addressTypes.add(prefix + 'Address');
      }
      return addressTypes;
    }
    
    public static List<String> getPrefixTypesForObject(String objectName) {
      if(objectName.equalsIgnoreCase('User') || objectName.equalsIgnoreCase('Lead')) {
        return new List<String>{''};
      }
      else if(objectName.equalsIgnoreCase('Account') || objectName.equalsIgnoreCase('ServiceContract')) {
        return new List<String>{'Billing', 'Shipping'};
      }
      else if(objectName.equalsIgnoreCase('Contact')) {
        return new List<String>{'Mailing', 'Other'};
      }
      return new List<String>{};
    }
    
    @AuraEnabled
    public static Sobject persistAddress(String address, String addressType, Id recordId) {
        System.debug('address: ' + address);
        String prefix = addressType.removeEndIgnoreCase('address');
        Sobject rec = fetchRecordObject(recordId, false);
            System.debug('rec: ' + rec);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(address);
        if(rec != null && !m.isEmpty()) {
            for(String key: m.keySet()) {
                rec.put(prefix+key, m.get(key));
            }
            upsert rec;
        }
        return rec;
    }
    
}