CLASS lhc_bookingsupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS SetBookingSuppId FOR DETERMINE ON SAVE
      IMPORTING keys FOR BookingSupplement~SetBookingSuppId.

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

ENDCLASS.

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookinDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookinDate.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingId.

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

ENDCLASS.
