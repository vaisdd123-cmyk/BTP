@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data definition Consumption Booking Supp'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZVK_BOOKINGSUP_C as projection on ZVK_BOOKINGSUP_I
{
    key BookingsupUuid,
    TravelUuid,
    BookingUuid,
    BookingSuppId,
    SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LocalLastChangedAt,
    /* Associations */
    _Booking : redirected to parent ZVK_BOOKING_C,
    _Travel : redirected to ZVK_TRAVEL_C
}
