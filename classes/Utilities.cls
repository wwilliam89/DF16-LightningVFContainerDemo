public with sharing class Utilities {

	public static List<String> getWhereConditionLabels(Map<String,Object> whereCondition, String listViewObject){
		List<Object> conditions = (List<Object>) whereCondition.get('conditions');

		// account for salesforce json package: if no filter conditions: conditions = (); if 1 filter condition conditions = null use whereCondition.field; if filter conditions > 1: conditions = ({field:...}, {field2:...})
		List<String> conditionLabels = new List<String>();

		System.debug(whereCondition);
		if (conditions != null){
		    if (conditions.isEmpty() != true){
		        for(Object condition : conditions){

		            Map<String,Object> conditionParams = (Map<String,Object>) condition;
		            String conditionString = (String)conditionParams.get('field');

		            // split string to isolate lookup fields
		            if (conditionString.countMatches('.') > 0){

		                List<String> lookupList = conditionString.split('[.]');

		                String lookupField = lookupList[0];

		                if(lookupField.contains('__r')){
		                    lookupField = lookupList[0].replace('__r', '__c');
		                }

		                String conditionLabel;

		                Schema.SObjectField fieldToDescribe = Schema.getGlobalDescribe().get(listViewObject).getDescribe().fields.getMap().get(lookupField);

		                if(fieldToDescribe == null){
		                    fieldToDescribe = Schema.getGlobalDescribe().get(listViewObject).getDescribe().fields.getMap().get(lookupField + 'Id');
		                    conditionLabel = fieldToDescribe.getDescribe().getLabel();
		                } else {
		                    conditionLabel = fieldToDescribe.getDescribe().getLabel();
		                }

		                conditionLabels.add(conditionLabel);

		                } else {

		                    String conditionLabel = Schema.getGlobalDescribe().get(listViewObject).getDescribe().fields.getMap().get(conditionString).getDescribe().getLabel();
		                    conditionLabels.add(conditionLabel);
		            }

		        }
		    }
		} else if (whereCondition.get('field') != null){

		    String field = (String) whereCondition.get('field');
		    String conditionLabel;

		    if (field.countMatches('.') > 0){

		        List<String> lookupList = field.split('[.]');

		        String lookupField = lookupList[0];

		        if(lookupField.contains('__r')){
		            lookupField = lookupField.replace('__r', '__c');
		        }


		        Schema.SObjectField fieldToDescribe = Schema.getGlobalDescribe().get(listViewObject).getDescribe().fields.getMap().get(lookupField);

		        if(fieldToDescribe == null){
		        	System.debug(lookupField);
		            fieldToDescribe = Schema.getGlobalDescribe().get(listViewObject).getDescribe().fields.getMap().get(lookupField + 'Id');
		            conditionLabel = fieldToDescribe.getDescribe().getLabel();
		        	System.debug(conditionLabel);

		        } else {
		            conditionLabel = fieldToDescribe.getDescribe().getLabel();
		        }

		        conditionLabels.add(conditionLabel);

		    } else {
		        conditionLabel = Schema.getGlobalDescribe().get(listViewObject).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
		    	conditionLabels.add(conditionLabel);
		    }

		}

		return conditionLabels;
	}

	public static void checkFieldsAreReadable(String sObjectName, String commaSeparatedFieldNames, String namespace) {

		String qualifiedName = namespace + sObjectName;
		Set<String> fieldNames = new Set<String>();

		fieldNames.addAll(commaSeparatedFieldNames.replace(' ', '').split(','));

		List<Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(qualifiedName).getDescribe().fields.getMap().values();

		for (Schema.SObjectField objectField : objectFields) {          
			Schema.DescribeFieldResult fieldDescribe = objectField.getDescribe();

			// Check if this field is accessible if it is a part of the passed in field names.
			if (fieldNames.contains(fieldDescribe.getName())) {
				if(!fieldDescribe.isAccessible()) { // If not accessible, throw an exception immediately
					throw new accessException('No Access to : ' + sObjectName + ' on field '+ fieldDescribe.getName());
				}
			}
		}
	}

	public static void checkFieldsAreReadable(String sObjectName, String commaSeparatedFieldNames){
		checkFieldsAreReadable(sObjectName, commaSeparatedFieldNames, '');
	}

	public class accessException extends Exception{

	}
}