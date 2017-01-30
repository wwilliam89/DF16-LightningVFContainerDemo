({
    initMap: function(component, event, helper) {
        window.addEventListener('message', $A.getCallback(function(postMessageEvent) {
            var leafletIframeCallback = component.find('leaflet-iframe').getElement();

            if (postMessageEvent && postMessageEvent.data === 'map init complete' && component.isValid()) {
                component.set('v.shouldShowMap', true);
                component.set('v.isMapInitialized', true);
                helper.hideSpinner(component, event, helper);

                var recordId = component.get('v.recordId');

                if (component.isValid() && recordId !== null) {
                    helper.generateMarker(component, event, helper);
                }
            }
        }), false);
    },

    generateMarker: function(component, event, helper) {
        var addressField = component.get('v.addressField');
        var recordId = event.getParam('recordId');
        var isMapInitialized = component.get('v.isMapInitialized');

        if (recordId == null && component.get('v.recordId')) {
            recordId = component.get('v.recordId');
        }

        if (isMapInitialized) {
            var action = component.get('c.getSelectedRecord');

            action.setParams({
                recordId: recordId,
                addressField: addressField
            });

            action.setStorable();

            action.setCallback(this, function(res) {

                if (component.isValid() && res.getState() === 'SUCCESS') {
                    var returnedRecord = JSON.parse(res.getReturnValue() || null);
                    var apiReturnValues = JSON.parse(returnedRecord.apiDetails);
                    var returnedRecordValues = returnedRecord.returnedObject;

                    if (apiReturnValues !== null && apiReturnValues.length > 0) {
                        var recordLat = apiReturnValues[0].lat;
                        var recordLon = apiReturnValues[0].lon;

                        var addressCoords = {
                            lat: parseFloat(recordLat),
                            long: parseFloat(recordLon)
                        };

                        component.set('v.recordAddress', returnedRecord.addressString);
                        component.set('v.recordName', returnedRecordValues[0].Name);
                        component.set('v.shouldShowMap', true);

                        this.showIcon(component);
                        this.showAddress(component);
                        this.hideSpinner(component);
                        component.set('v.showEmpty', false);
                        helper.sendPanMessageToMap(component, addressCoords);

                    } else {
                        component.set('v.recordAddress', returnedRecord.addressString);
                        component.set('v.recordName', returnedRecordValues[0].Name);
                        component.set('v.shouldShowMap', false);
                        component.set('v.showEmpty', true);

                        this.showIcon(component);
                        this.showAddress(component);
                        this.hideSpinner(component);
                    }
                }

            });
            $A.enqueueAction(action);
        } else {
            component.set('v.recordId', recordId);
        }
    },

    hideSpinner: function(component, event, helper) {
        var cmpTarget = component.find('spinner');
        $A.util.removeClass(cmpTarget, 'ld-ic-hide-spinner');
        $A.util.addClass(cmpTarget, 'slds-hide ld-ic-show-spinner');
    },


    showIcon: function(component, event, helper) {
        var cmpTarget = component.find('icon');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },

    hideAddress: function(component, event, helper) {
        var cmpTarget = component.find('address');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },

    showAddress: function(component, event, helper) {
        var cmpTarget = component.find('address');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    
    sendPanMessageToMap: function(component, addressCoords) {
        var leafletIframe = component.find('leaflet-iframe').getElement();

        leafletIframe.contentWindow.postMessage(addressCoords, '*');
    }

})