# Staff Key Transaction Requirements

## Purpose

Build a staff-only tenant search feature for a key return and key collection app.

The feature allows authorised staff to search for a tenant by name, select the correct tenant and property/unit combination, and then continue with either a key return or key collection transaction.

The initial implementation uses Microsoft Power Apps with SharePoint Lists as the data source.

## Core Requirements

Staff must be able to:

1. Start from a staff welcome screen.
2. Choose the transaction type:
   - Key Return
   - Key Collection
3. Search for a tenant by typing part of the tenant's name.
4. View matching tenants in a limited search results list.
5. Select the correct tenant based on name and property/unit combination.
6. Confirm the selected tenant before continuing.
7. Continue to the key transaction screen with selected tenant details pre-filled.
8. Submit a key transaction record to SharePoint.
9. Return automatically to the welcome screen after inactivity.

## Privacy and Data Minimisation

The search feature must be staff-facing only.

Tenants must not be able to browse or search tenant records.

Search results should display only the minimum information needed for staff to identify the correct person:

- tenant full name
- property name/address
- room/studio/flat reference
- partially masked email address
- tenant status

Avoid showing these fields in search results:

- full email address
- phone number
- date of birth
- payment history
- deposit status
- guarantor details
- other occupants
- sensitive notes

Example search result:

```text
John Smith
Studio 15, Campus View
jon*****@example.com
Incoming
```

## SharePoint List: TenantTracker

This list holds one record per tenant, tenancy, and room allocation.

| Column Name | Type | Required | Notes |
|---|---:|---:|---|
| TenantID | Single line text | Yes | Unique internal ID |
| FirstName | Single line text | Yes | Tenant first name |
| LastName | Single line text | Yes | Tenant surname |
| FullName | Single line text | Yes | Used for search and display |
| Email | Single line text | Yes | Used for confirmation email or receipt |
| PropertyName | Single line text | Yes | Property name or address |
| UnitReference | Single line text | No | Studio, flat, room, or unit reference |
| TenancyYear | Single line text | Yes | Example: `2026-2027` |
| TenantStatus | Choice | Yes | Incoming, Current, Outgoing, Completed, Cancelled |
| ExpectedMoveInDate | Date | No | Useful for collections |
| ExpectedMoveOutDate | Date | No | Useful for returns |
| IsActiveForKeyApp | Yes/No | Yes | Allows records to be hidden from the app |

## SharePoint List: KeyTransactions

This list stores one submitted key transaction per record.

| Column Name | Type | Notes |
|---|---:|---|
| TransactionID | Single line text | Unique transaction reference |
| TransactionType | Choice | Return / Collection |
| TenantID | Single line text | Snapshot from `TenantTracker` |
| TenantName | Single line text | Snapshot at time of transaction |
| TenantEmail | Single line text | Used for email receipt |
| PropertyName | Single line text | Snapshot at time of transaction |
| UnitReference | Single line text | Snapshot at time of transaction |
| FDCount | Number | Front door keys |
| RKCount | Number | Room keys |
| FobCount | Number | Fobs |
| MailboxKeyCount | Number | Mailbox keys |
| OtherKeysDescription | Multiple lines text | Optional |
| TenantSignatureJson | Multiple lines text | Optional MVP storage for pen input JSON |
| StaffName | Single line text | Staff member processing transaction |
| StaffSignatureJson | Multiple lines text | Optional MVP storage for pen input JSON |
| SubmittedAt | Date/time | App generated |
| Notes | Multiple lines text | Optional |

For production use, consider saving signatures as SharePoint attachments or image files through Power Automate rather than storing image JSON in list columns.

## Transaction Filtering Logic

Key return search results should show active records where `TenantStatus` is:

- Outgoing
- Current

Key collection search results should show active records where `TenantStatus` is:

- Incoming
- Current

## Acceptance Criteria

The feature is complete when:

1. Staff can start from a welcome screen.
2. Staff can select either Key Return or Key Collection.
3. Staff can search tenants by partial name.
4. Search results are filtered by transaction type.
5. Search results show tenant name and property/unit combination.
6. Search results do not expose unnecessary personal data.
7. Staff can select the correct tenant.
8. The selected tenant is stored in a variable.
9. Staff can confirm the selected tenant before proceeding.
10. Tenant details are passed into the key transaction form.
11. The final transaction record stores the selected tenant ID, name, property, unit, and email.
12. The app clears in-progress data and returns to the welcome screen after inactivity.

## Version 1 Scope

Included:

- manual tenant import into SharePoint
- welcome/start screen
- inactivity return to welcome screen
- staff name search
- transaction type filtering
- tenant selection
- tenant confirmation screen
- handoff to key details screen
- SharePoint transaction submission

Excluded:

- integration with property management systems
- tenant self-search
- payment or deposit tracking
- dashboards
- PDF generation
- QR code scanning
- automated tenant import

## Future Enhancements

Potential later improvements:

- QR code lookup from tenant email
- import tenant data from Excel or another system
- move-in readiness checklist
- move-out checklist
- admin dashboard
- duplicate tenant warning
- expected key templates per property/unit

## Design Principle

The tenant search should make the staff task quicker without turning the app into a tenant directory.

Show staff enough information to identify the correct tenant, but no more than is needed for the key transaction.
