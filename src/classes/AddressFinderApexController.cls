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
    public static Sobject fetchRecord(Id recordId, Boolean aggregated) {
        String fieldsToShow = aggregated ? 'Address' : 'street, city, state, postalCode, country';
        if(recordId != null) {
          String objectName = recordId.getSobjectType().getDescribe().getName();
          String soql = 'Select ' + fieldsToShow + ' from ' + objectName + ' where Id = :recordId';
          Sobject rec = Database.query(soql);
          return (rec == null ? recordId.getSobjectType().newSObject() : rec);
        }
        return null;
    }
    
    @AuraEnabled
    public static Sobject persistAddress(String address, Id recordId) {
        Sobject rec = fetchRecord(recordId, false);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(address);
        if(rec != null && !m.isEmpty()) {
            for(String key: m.keySet()) {
                rec.put(key, m.get(key));
            }
            upsert rec;
        }
        return rec;
    }
    
}