public with sharing class MapController {

	@AuraEnabled
	public static String getSelectedRecord(Id recordId, String addressField){

		String objectName = recordId.getSObjectType().getDescribe().getName();

		String queryString = 'SELECT ';

        if (objectName != 'Event') {
            queryString += 'Name, ';
            String recordFields = 'Name, ' + addressField;
            Utilities.checkFieldsAreReadable(objectName, recordFields);
        } else {
        	String recordFields = addressField;
        	Utilities.checkFieldsAreReadable(objectName, recordFields);
        }

        queryString += addressField + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
        System.debug(queryString);

		List<Object> returnedObject = Database.query(String.escapeSingleQuotes(queryString));
		System.debug(returnedObject);
		Http http = new Http();
		HttpRequest req = new HttpRequest();

		SObject returnedObjectMap = (SObject) returnedObject[0];

		String returnedAddress;

		if (Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(addressField).getDescribe().getType() == Schema.DisplayType.Address && returnedObjectMap.get(addressField) != null){
			Address addressFieldType = (Address)returnedObjectMap.get(addressField);
			returnedAddress = addressFieldType.getStreet() + ' ' + addressFieldType.getCity() + ', ' + addressFieldType.getState() + ' ' + addressFieldType.getPostalCode();
		} else if (returnedObjectMap.get(addressField) == null) {
			returnedAddress = '';
		} else {
			returnedAddress = (String)returnedObjectMap.get(addressField);
		}

		String encodedAddress = EncodingUtil.urlEncode(returnedAddress, 'UTF-8');


		String endpointString = 'https://nominatim.openstreetmap.org/search?q=' + encodedAddress + '&format=json&limit=1&addressdetails=1';
		req.setEndpoint(endpointString);
		req.setMethod('GET');


		HttpResponse res = http.send(req);

		System.debug(res.getBody());

		Map<String,Object> sendMap = new Map<String,Object>();

        sendMap.put('addressString', returnedAddress);
		sendMap.put('returnedObject', returnedObject);
		sendMap.put('apiDetails', (Object)res.getBody());

		return JSON.serialize(sendMap);

	}

    @AuraEnabled
	public static String getSelectedRecordWithoutGeolocation(Id recordId, String addressField){
		String objectName;
		Map<String,Object> sendMap = new Map<String,Object>();


		objectName = recordId.getSObjectType().getDescribe().getName();


		String queryString = 'SELECT ';

        if (objectName != 'Event') {
            queryString += 'Name, ';
            String recordFields = 'Name, ' + addressField;
            Utilities.checkFieldsAreReadable(objectName, recordFields);
        } else {
        	String recordFields = addressField;
        	Utilities.checkFieldsAreReadable(objectName, recordFields);
        }

		queryString += addressField + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';

		List<Object> returnedObject = Database.query(String.escapeSingleQuotes(queryString));

		SObject returnedObjectMap = (SObject) returnedObject[0];

		String returnedAddress;

		if (Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(addressField).getDescribe().getType() == Schema.DisplayType.Address && returnedObjectMap.get(addressField) != null){
			Address addressFieldType = (Address)returnedObjectMap.get(addressField);
			returnedAddress = addressFieldType.getStreet() + ' ' + addressFieldType.getCity() + ', ' + addressFieldType.getState() + ' ' + addressFieldType.getPostalCode();
		} else if (returnedObjectMap.get(addressField) == null) {
			returnedAddress = '';
		} else {
			returnedAddress = (String)returnedObjectMap.get(addressField);
		}



        sendMap.put('addressString', returnedAddress);
		sendMap.put('returnedObject', returnedObject);

		return JSON.serialize(sendMap);
	}
}