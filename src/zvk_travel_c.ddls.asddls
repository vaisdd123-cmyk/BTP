@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data definition Consumption Travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZVK_TRAVEL_C as projection on ZVK_TRAVEL_I
{
    key TravelUuid,
    TravelId,
    AgencyId,
    @ObjectModel.text.element: [ 'CustomerName' ]
    @UI.textArrangement: #TEXT_LAST
    CustomerId,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Description,
    OverallStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    _Customer.FirstName as CustomerName,
    /* Associations */
    _Booking : redirected to composition child ZVK_BOOKING_C
}
