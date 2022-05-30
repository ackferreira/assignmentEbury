public with sharing class SObjectUtils {

    public static Schema.DescribeSObjectResult getSObjectDescribe(String objectTypeName) {
        try {
            return Schema.getGlobalDescribe().get(objectTypeName).getDescribe();
        }
        catch(Exception ex) {
            throw new SObjectUtilsException('sObject not found');
        }
    }

    public static Schema.DescribeFieldResult getFieldDescribe(Schema.DescribeSObjectResult objectDescribe, String fieldName) {
        try {
            return objectDescribe.fields.getMap().get(fieldName).getDescribe();
        }
        catch(Exception ex) {
            throw new SObjectUtilsException('Field not found for object');
        }
    }

    public static List<string> getPicklistValuesList(String objectTypeName, String picklistFieldName) {
        List<String> picklistValues = new List<String>();
        Schema.DescribeSObjectResult objectDescribe = getSObjectDescribe(objectTypeName);
        Schema.DescribeFieldResult picklistDescribe = getFieldDescribe(objectDescribe, picklistFieldName);
        try{
            for (Schema.PicklistEntry picklistVal : picklistDescribe.getPicklistValues()){
                picklistValues.add(picklistVal.getValue());
            }     
            return picklistValues;
        }
        catch(Exception ex) {
            throw new SObjectUtilsException('Unable to retrieve picklist values');
        }
    }
    
    public class SObjectUtilsException extends Exception {} 
}
