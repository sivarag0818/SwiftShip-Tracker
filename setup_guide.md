# SwiftShip Tracker

Salesforce Flow + Agentforce project that retrieves a customer's latest shipment,
classifies its delivery risk, creates follow-up tasks for delayed shipments, and
responds to the customer through an Agentforce subagent.

## 1. Prerequisites & Custom Object Setup
1. **Custom Object:** `SwiftShip_Tracker__c`
2. **Fields:**
   - `Customer__c` (Lookup → Account)
   - `Tracking_Number__c` (Text, Unique)
   - `Shipment_Status__c` (Picklist: Booked, In Transit, Out for Delivery, Delivered, Delayed, Returned)
   - `Shipment_Notes__c` (Long Text Area)
   - `Estimated_Delivery_Date__c` (Date)
3. **Standard Objects:** `Account`, `Task`, `User`

## 2. Flow Variables
| Variable | Type | Availability |
|---|---|---|
| `varAccountName` | Text | Input |
| `varAccountId` | Text | Output |
| `varShipmentId` | Text | Output |
| `varTrackingNumber` | Text | Output |
| `varRiskLevel` | Text | Output |
| `varAssignedTo` | Text | Output |
| `varActionMessage` | Text | Output |

## 3. Flow Configuration (`SwiftShip_Tracker_Flow`)

### A. Retrieval
1. **Get Records:** `Account` where `Name = {!varAccountName}`, sort `CreatedDate` DESC, first record only
2. **Assignment:** `varAccountId = {!Get_Account.Id}`
3. **Get Records:** `SwiftShip_Tracker__c` where `Customer__c = {!varAccountId}`, sort `CreatedDate` DESC, first record only
4. **Assignment:** `varShipmentId = {!Get_Shipment.Id}`, `varTrackingNumber = {!Get_Shipment.Tracking_Number__c}`

### B. Risk Analysis (Decision)
- **High Risk:** Status equals `Delayed` OR notes contain `"damaged"`, `"lost"`, `"customs hold"`
- **Medium Risk:** Estimated delivery date is before today and status is not `Delivered`, OR notes contain `"rescheduled"`, `"weather"`
- **Default:** Low Risk

Assignments set `varRiskLevel` to High / Medium / Low.

### C. Escalation
5. **Decision:** `varRiskLevel = "High"`
6. **Create Records (Task):**
   - `Subject` = "Delayed Shipment Follow-up"
   - `WhatId` = `{!varShipmentId}`
   - `Priority` = High, `Status` = Not Started
7. **Assignment:** `varAssignedTo = "Logistics Manager"`

### D. Final Messages
- High: "Shipment is delayed or at risk. Escalated to logistics manager."
- Medium: "Shipment may be late. Our team is monitoring it."
- Low: "Shipment is on track for delivery."

Save and **Activate** the flow.

## 4. Agentforce Subagent
1. Open **Agentforce Builder** and create a subagent: **Shipment Tracking Assistant**
2. Set the classification description and scope to shipment status queries only
3. Add the flow as an action: input `varAccountName`; outputs `varActionMessage`, `varRiskLevel`, `varAssignedTo`, `varShipmentId`, `varTrackingNumber`, `varAccountId`
4. Test in **Conversation Preview** with a valid account name

## 5. Sample Test Data
| Account | Status | Notes | Expected Risk |
|---|---|---|---|
| Acme Corp | Delayed | Customs hold at port | High |
| Globex | In Transit | Weather rescheduled | Medium |
| Initech | Out for Delivery | None | Low |

## 6. Future Enhancements
- Email alert to customer on High risk
- Integration with a carrier API (FedEx/DHL) via External Services
- Dashboard of delayed shipments by region

## Tech Stack
Salesforce Developer Org · Flow Builder · Agentforce · Custom Objects
