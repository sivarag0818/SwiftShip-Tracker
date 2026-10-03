public with sharing class SwiftShipTracker {

    @AuraEnabled
    public static Map<String, Object> trackShipment(String trackingNumber) {

        Map<String, Object> response = new Map<String, Object>();

        if (String.isBlank(trackingNumber)) {
            response.put('success', false);
            response.put('message', 'Please enter a tracking number.');
            return response;
        }

        List<Shipment__c> shipments = [
            SELECT Id,
                   Name,
                   Tracking_Number__c,
                   Carrier__c,
                   Status__c,
                   Origin__c,
                   Destination__c,
                   Current_Location__c,
                   Estimated_Delivery__c,
                   Actual_Delivery__c
            FROM Shipment__c
            WHERE Tracking_Number__c = :trackingNumber
            LIMIT 1
        ];

        if (shipments.isEmpty()) {
            response.put('success', false);
            response.put(
                'message',
                'No shipment found for tracking number: ' +
                trackingNumber
            );
            return response;
        }

        Shipment__c shipment = shipments[0];

        List<Tracking_Event__c> events = [
            SELECT Id,
                   Status__c,
                   Location__c,
                   Event_Date_Time__c,
                   Description__c
            FROM Tracking_Event__c
            WHERE Shipment__c = :shipment.Id
            ORDER BY Event_Date_Time__c DESC
        ];

        response.put('success', true);
        response.put('message', 'Shipment found successfully.');

        response.put('shipmentId', shipment.Id);
        response.put('trackingNumber',
                     shipment.Tracking_Number__c);
        response.put('carrier',
                     shipment.Carrier__c);
        response.put('status',
                     shipment.Status__c);
        response.put('origin',
                     shipment.Origin__c);
        response.put('destination',
                     shipment.Destination__c);
        response.put('currentLocation',
                     shipment.Current_Location__c);
        response.put('estimatedDelivery',
                     shipment.Estimated_Delivery__c);
        response.put('actualDelivery',
                     shipment.Actual_Delivery__c);

        List<Map<String, Object>> trackingHistory =
            new List<Map<String, Object>>();

        for (Tracking_Event__c eventRecord : events) {

            trackingHistory.add(
                new Map<String, Object>{
                    'status' =>
                        eventRecord.Status__c,

                    'location' =>
                        eventRecord.Location__c,

                    'eventDateTime' =>
                        eventRecord.Event_Date_Time__c,

                    'description' =>
                        eventRecord.Description__c
                }
            );
        }

        response.put(
            'trackingHistory',
            trackingHistory
        );

        return response;
    }
}
