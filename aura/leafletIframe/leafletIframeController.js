({
    onInit: function(component, event, helper) {
        helper.initMap(component, event, helper);
    },

    recordSelected: function(component, event, helper) {
        helper.generateMarker(component, event, helper);
    },

    clickClick: function(component, event, helper) {
        // var leafletIframe = component.find('leaflet-iframe').getElement();
        //
        // leafletIframe.contentWindow.postMessage({ a: 'test'}, '*');
    },

    clickAddress: function(component, event, helper) {
        var address = component.get('v.recordAddress');
        var urlEvent = $A.get("e.force:navigateToURL");

        urlEvent.setParams({
            'url': 'https://www.google.com/maps/place/' + address
        });

        urlEvent.fire();
    },

})