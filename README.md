# ktlib-convert-to-itinerary

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=Kpatio&repo=ktlib-convert-to-itinerary)

Contains unmanaged base classes and metadata for lead to itinerary conversion.

## How it works
This repo contains 1 trigger and 2 classes and several custom fields on the Lead SObject that control the conversion process for new leads.
The idea is to use the Lead SObject as a short-term container of enquiry information, and on insert automatically convert the Lead into a new Person Account & Itinerary.
End users therefore never use the Lead object, but we use the simple Web-to-lead online forms to capture information that creates itineraries for agents to work on.

## Fields on Lead SObject that control conversion
 * AutoConvertToItinerary__c - Checbox. If set to true, lead will auto convert to Person Account + Itinerary.

 * AutoConvertToPersonAccount__c - Checkbox. If set to true, lead will auto convert to Person Account only.

 * StartDate__c & EndDate__c - date fields & GroupSize__c - Number field. Information used to create an Itinerary.

 * LanguagePreference__c. Used to map to the appropriate channel via the ChannelMapper class. If user selects "English" as language of choice, we can push "en_UK" into this field. If we then have "en_UK" as the Channel Code for a certain channel, the Itinerary will be assigned to this channel.

 * UpdateExistingPersonAccount__c
 If selected, we run custom code for additional Lead to Account field mapping. This can also be extended to decide whether we update Account that have the same email address as a certain lead.

## Todo list
* Reconsider exception handling
* Improve unit tests.
