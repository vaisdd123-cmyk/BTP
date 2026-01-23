@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement I'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZVK_BOOKINGSUP_I as select from zvk_bookingsup
association to parent ZVK_BOOKING_I as _Booking on $projection.BookingUuid = _Booking.BookingUuid
association [1] to  ZVK_TRAVEL_I as _Travel on $projection.TravelUuid = _Travel.TravelUuid
{
    key bookingsup_uuid as BookingsupUuid,
    root_uuid as TravelUuid,
    parent_uuid as BookingUuid,
    booking_supp_id as BookingSuppId,
    supplement_id as SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    local_last_changed_at as LocalLastChangedAt,
    _Booking,
    _Travel
}
