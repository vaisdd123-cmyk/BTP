@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data definition Consumption Booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZVK_BOOKING_C as projection on ZVK_BOOKING_I
{
    key BookingUuid,
    TravelUuid,
    BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LocalLastChangedAt,
    /* Associations */
    _BookingSupplement : redirected to composition child ZVK_BOOKINGSUP_C,
    _Travel : redirected to parent ZVK_TRAVEL_C
}
