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
    public static Sobject fetchRecord(Id recordId, String fieldsToShow) {
        String objectName = recordId.getSobjectType().getDescribe().getName();
        String soql = 'Select ' + fieldsToShow + ' from ' + objectName + ' where Id = :recordId';
        Sobject rec = Database.query(soql);
        return rec;
    }
    
}