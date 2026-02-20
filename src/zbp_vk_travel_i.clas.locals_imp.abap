CLASS lhc_bookingsupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS SetBookingSuppId FOR DETERMINE ON SAVE
      IMPORTING keys FOR BookingSupplement~SetBookingSuppId.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSupplement~calculateTotalPrice.

ENDCLASS.

CLASS lhc_bookingsupplement IMPLEMENTATION.

  METHOD SetBookingSuppId.

  DATA : max_bookingsupplid TYPE ZBSUP_ID,
         bookingsuppliment TYPE STRUCTURE FOR READ RESULT ZVK_BOOKINGSUP_I,
         bookingsuppl_update TYPE TABLE FOR UPDATE ZVK_TRAVEL_I\\BookingSupplement.

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY BookingSupplement BY \_Booking
  FIELDS ( BookingUuid )
  WITH CORRESPONDING #( keys )
  RESULT DATA(bookings).

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Booking BY \_BookingSupplement
  FIELDS (  BookingsupUuid )
  WITH CORRESPONDING #( bookings )
  LINK DATA(bookingsuppl_links)
  RESULT DATA(Bookingsuppliments).

  LOOP AT bookings INTO DATA(booking).

  " Initialize the Booking ID number

  max_bookingsupplid = '00'.

  LOOP AT bookingsuppl_links INTO DATA(bookingsuppl_link) USING KEY ID WHERE source-%tky = booking-%tky.

  bookingsuppliment = Bookingsuppliments[ key id
                      %tky = bookingsuppl_link-target-%tky ].

  IF bookingsuppliment-BookingSuppId > max_bookingsupplid.

  max_bookingsupplid = bookingsuppliment-BookingSuppId.

  ENDIF.

  ENDLOOP.


  LOOP AT bookingsuppl_links INTO bookingsuppl_link USING KEY ID WHERE source-%tky = booking-%tky.

  bookingsuppliment = Bookingsuppliments[ key id
                      %tky = bookingsuppl_link-target-%tky ].

  IF bookingsuppliment-BookingSuppId IS INITIAL.

  max_bookingsupplid += 1.

  APPEND VALUE #( %tky = bookingsuppliment-%tky
                 BookingSuppId = max_bookingsupplid )
                 to bookingsuppl_update.

  ENDIF.
  ENDLOOP.
  ENDLOOP.

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY BookingSupplement
  UPDATE FIELDS ( BookingSuppId )
  WITH bookingsuppl_update.


  ENDMETHOD.

  METHOD calculateTotalPrice.

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY BookingSupplement BY \_Travel
  FIELDS ( TravelUuid )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  EXECUTE reCalTotalPrice
  FROM CORRESPONDING #( travels ).



  ENDMETHOD.

ENDCLASS.

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookinDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookinDate.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingId.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD setBookinDate.
  ENDMETHOD.

  METHOD setBookingId.

  DATA : max_bookingid TYPE ZB_ID,
         booking TYPE STRUCTURE FOR READ RESULT ZVK_BOOKING_I,
         bookings_update TYPE TABLE  FOR UPDATE ZVK_TRAVEL_I\\Booking.


" We are reading Booking entity  to get the Uuid field for the current booking instance and store that in travels table

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Booking BY \_Travel
  FIELDS ( TravelUuid )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

" Now read all the booking related to travel details which we got from the travels table

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel BY \_Booking
  FIELDS ( BookingId )
  WITH CORRESPONDING #( travels )
  LINK DATA(booking_links)
  RESULT DATA(bookings).

  LOOP AT travels INTO DATA(travel).

  " Initialize the Booking ID number

  max_bookingid = '0000'.

  LOOP AT booking_links INTO DATA(booking_link) USING KEY ID WHERE source-%tky = travel-%tky.

  booking = bookings[ key id
                      %tky = booking_link-target-%tky  ].

  if booking-BookingId > max_bookingid.

  max_bookingid = booking-BookingId.

  ENDIF.
  ENDLOOP.

  LOOP AT booking_links INTO booking_link USING KEY ID WHERE source-%tky = travel-%tky.

  booking = bookings[ key id
                      %tky = booking_link-target-%tky  ].

  IF booking-Bookingid IS INITIAL.

  max_bookingid += 1.

  APPEND VALUE #( %tky = booking-%tky
                  BookingId = max_bookingid
                   ) to bookings_update.

  ENDIF.
  ENDLOOP.
  ENDLOOP.

  " Use Modify EML to Update the Bookings entity with the new Booking id num which is max_bookingid

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Booking
  UPDATE FIELDS ( Bookingid )
  WITH bookings_update.

  ENDMETHOD.

  METHOD calculateTotalPrice.

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Booking BY \_Travel
  FIELDS ( TravelUuid )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  EXECUTE reCalTotalPrice
  FROM CORRESPONDING #( travels ).



  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS setTravelId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelId.
    METHODS setOverallStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setOverallStatus.
    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.
    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.
    METHODS GetDefaultsForDeductDiscount FOR READ
      IMPORTING keys FOR FUNCTION Travel~GetDefaultsForDeductDiscount RESULT result.
    METHODS reCalTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalTotalPrice.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.


ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setTravelId.

  " Read the Travel entity using EML

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  FIELDS ( TravelId )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_travel).

  " Delete the record where travel id is already existing

  DELETE lt_travel where TravelId IS NOT INITIAL.

  SELECT SINGLE FROM ZVK_TRAVEL FIELDS MAX( travel_id ) into @DATA(lv_travelid_max).

  " Modify EML Statement

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  UPDATE FIELDS ( TravelId )
  WITH VALUE #( for ls_travel_id in lt_travel INDEX INTO lv_index
               ( %tky = ls_travel_id-%tky
                 TravelId = lv_travelid_max + lv_index ) ).


  ENDMETHOD.

  METHOD setOverallStatus.

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  FIELDS ( OverallStatus )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_status).

  DELETE lt_status WHERE OverallStatus IS NOT INITIAL.

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  UPDATE FIELDS ( OverallStatus )
  WITH VALUE #(  for ls_status in lt_status
                ( %tky = ls_status-%tky
                OverallStatus = 'O' ) ).



  ENDMETHOD.

  METHOD acceptTravel.

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  UPDATE FIELDS ( OverallStatus )
  WITH VALUE #( for key IN KEYS ( %tky = key-%tky
                                  OverallStatus = 'A' ) ).

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(travels).


  result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                            %param = travel ) ).

  ENDMETHOD.

  METHOD rejectTravel.

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  UPDATE FIELDS ( OverallStatus )
  WITH VALUE #( for key IN KEYS ( %tky = key-%tky
                                  OverallStatus = 'R' ) ).

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(travels).


  result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                            %param = travel ) ).
  ENDMETHOD.

  METHOD deductDiscount.

  DATA : travel_for_update TYPE TABLE FOR UPDATE ZVK_TRAVEL_I.

  data(keys_temp) = keys.

* Checking the validation for the Discount if it is >0 or <100.

 LOOP AT keys_temp ASSIGNING FIELD-SYMBOL(<key_temp>) WHERE %param-discount_percent is INITIAL or
                                                            %param-discount_percent  > 100 or
                                                            %param-discount_percent < 0.

  APPEND VALUE #( %tky = <key_temp>-%tky ) to failed-travel.
  APPEND VALUE #( %tky = <key_temp>-%tky
                  %msg = new_message_with_text( text = 'Invalid Discount Percentage'
                                                severity = if_abap_behv_message=>severity-error )
                  %element-totalprice = if_abap_behv=>mk-on
                  %action-deductDiscount = if_abap_behv=>mk-on ) to reported-travel.

  delete keys_temp.
  ENDLOOP.

  CHECK keys_temp is NOT INITIAL.

* Reading Travel data
  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  FIELDS ( TotalPrice )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_travels).

  data : lv_percentage type decfloat16.

  LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

  DATA(lv_discount_percent) = keys[ key id %tky = <fs_travel>-%tky ]-%param-discount_percent.

  lv_percentage = lv_discount_percent / 100.

  data(reduced_value) = <fs_travel>-TotalPrice * lv_percentage.
  reduced_value = <fs_travel>-TotalPrice - reduced_value.

  APPEND VALUE #( %tky = <fs_travel>-%tky
                  totalprice = reduced_value ) to travel_for_update.

  ENDLOOP.

* Updating Travel BO

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  UPDATE FIELDS ( TotalPrice )
  WITH travel_for_update.

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(lt_travel_updated).

* Sending back that information by using the Result  Parameter.

  result = value #( for ls_travel in lt_travel_updated ( %tky = ls_travel-%tky
                                                         %param = ls_travel ) ).




  ENDMETHOD.

  METHOD GetDefaultsForDeductDiscount.

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  FIELDS ( TotalPrice )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

  LOOP AT travels INTO DATA(travel).
  IF travel-TotalPrice >= 4000.
     APPEND VALUE #( %tky = travel-%tky
                     %param-discount_percent = 30 ) TO result.

  ELSE.
        APPEND VALUE #( %tky = travel-%tky
                     %param-discount_percent = 15 ) TO result.
  ENDIF.
  ENDLOOP.

  ENDMETHOD.

  METHOD reCalTotalPrice.

  TYPES :BEGIN OF ty_amount_per_currencycode,
         amount TYPE /dmo/total_price,
         currency_code TYPE /dmo/currency_code,
         END OF ty_amount_per_currencycode.

   DATA : amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  FIELDS ( bookingfee currencycode )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel BY \_Booking
  FIELDS ( flightprice currencycode )
  WITH CORRESPONDING #( travels )
  RESULT DATA(bookings)
  LINK DATA(booking_links).


  READ ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Booking BY \_BookingSupplement
  FIELDS ( Price currencycode )
  WITH CORRESPONDING #( bookings )
  RESULT DATA(bookingsuppliments)
  LINK DATA(bookingsuppliment_links).

  LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

  amounts_per_currencycode = VALUE #( ( amount = <travel>-BookingFee
                                        currency_code = <travel>-CurrencyCode ) ).

  LOOP AT booking_links INTO DATA(booking_link) using key id WHERE source-%tky = <travel>-%tky.

  DATA(booking) = bookings[ key id %tky = booking_link-target-%tky ].

  COLLECT VALUE ty_amount_per_currencycode( amount = booking-flightprice
                                            currency_code = booking-CurrencyCode ) INTO amounts_per_currencycode.

  LOOP AT bookingsuppliment_links INTO DATA(bookingsuppliment_link) USING KEY ID WHERE source-%tky = booking-%tky.

  DATA(bookingsuppliment) = bookingsuppliments[ key id %tky = bookingsuppliment_link-target-%tky ].

  COLLECT VALUE ty_amount_per_currencycode( amount = bookingsuppliment-price
                                            currency_code = bookingsuppliment-CurrencyCode ) INTO amounts_per_currencycode.



  ENDLOOP.
  ENDLOOP.
  ENDLOOP.

  DELETE amounts_per_currencycode WHERE currency_code IS INITIAL.
  LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).

" Travel USD -> PARENT - Total Price
" Booking EUR -> USD
" Booking Suppl EUR -> USD

  IF <travel>-CurrencyCode = amount_per_currencycode-currency_code.

    <travel>-TotalPrice += amount_per_currencycode-amount.

  ELSE.

   /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
              iv_amount = amount_per_currencycode-amount
              iv_currency_code_source = amount_per_currencycode-currency_code
              iv_currency_code_target = <travel>-CurrencyCode
              iv_exchange_rate_date = cl_abap_context_info=>get_system_date( )
              IMPORTING
               ev_amount =  DATA(total_booking_price_per_curr) ).

       <travel>-TotalPrice += total_booking_price_per_curr.

 ENDIF.

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  UPDATE FIELDS ( TotalPrice )
  WITH CORRESPONDING #( travels ).

 ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.

  MODIFY ENTITIES OF ZVK_TRAVEL_I IN LOCAL MODE
  ENTITY Travel
  EXECUTE reCalTotalPrice
  FROM CORRESPONDING #( keys ).




  ENDMETHOD.

ENDCLASS.
