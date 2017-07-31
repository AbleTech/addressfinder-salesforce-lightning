public with sharing class AddressFinderApexController {
    
    @AuraEnabled
    public static String getConfigKey() {
        List<Config__C> configs = Config__C.getAll().values();
        if(configs != null && configs.size() > 0) {
            return configs[0].Key__c;
        }
        return null;
    }
    
    @AuraEnabled
    public static String getConfigCountryCode() {
        List<Config__C> configs = Config__C.getall().values();
        if(configs != null && configs.size() > 0) {
            return configs[0].Country_Code__c;
        }
        return null;
    }
    
    @AuraEnabled
    public static String getAppVersion() {
        Version version = System.requestVersion();
        if(version != null) {
            return version.major() + '.' + version.minor();
        }
        return 'unknown';
    }
    
    @AuraEnabled
    public static Sobject fetchRecord(Id recordId, Boolean aggregated) {
        String fieldsToShow = getFieldNames(aggregated);
        String objectName = recordId.getSobjectType().getDescribe().getName();
        String soql = 'Select ' + fieldsToShow + ' from ' + objectName + ' where Id = :recordId';
        Sobject rec = Database.query(soql);
        if(rec == null) {
            rec = recordId.getSobjectType().newSObject();
        }
        return rec;
    }
    
    private static String getFieldNames(Boolean aggregated) {
        String fieldsToShow;
        if(aggregated) {
            fieldsToShow = 'Address';
        }
        else {
            fieldsToShow = 'street, city, state, postalCode, country';
        }
        return fieldsToShow;
    }
    
    @AuraEnabled
    public static void persistAddress(String address, Id recordId) {
      Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(address);
        if(!m.isEmpty()) {
            Sobject rec = fetchRecord(recordId, false);
            if(rec != null) {
                for(String key: m.keySet()) {
                    rec.put(key, m.get(key));
                }
                System.debug(JSON.serialize (rec));
                upsert rec;
            }
        }
    }
    
}