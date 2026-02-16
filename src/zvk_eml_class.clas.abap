CLASS zvk_eml_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .


  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS simple_eml_form_create.


ENDCLASS.



CLASS ZVK_EML_CLASS IMPLEMENTATION.


    METHOD if_oo_adt_classrun~main.

* EML Creation and Creating Entity for Travel CDS View only
* %CID value will automatically assign the UUID for us.

    MODIFY ENTITY ZVK_TRAVEL_I
    CREATE
    SET FIELDS WITH VALUE #( ( %cid = 'D1'
                               AgencyId = 'V01'
                               Description = 'New Agency Number V01'
                               BookingFee = 999
                               TotalPrice = 999
                               OverallStatus = 'A'
                               CurrencyCode = 'INR'
                               BeginDate = cl_abap_context_info=>get_system_date( )
                               EndDate = cl_abap_context_info=>get_system_date(  ) + 3 ) )


    FAILED DATA(lt_create_failed)
    REPORTED DATA(lt_create_reported).

    COMMIT ENTITIES
    RESPONSE OF ZVK_TRAVEL_I
    FAILED DATA(lt_commit_failed)
    REPORTED DATA(lt_commit_reported).

    out->write( 'case-1 : New Travel record created' ).

* Creating Entity for Booking CDS with Travel

    MODIFY ENTITY ZVK_TRAVEL_I
    CREATE
    FIELDS ( AgencyId Description BookingFee TotalPrice OverallStatus CurrencyCode BeginDate EndDate )
    WITH VALUE #( ( %cid = 'V02'
                    AgencyId = 'V02'
                    Description = 'New Agency Number V02'
                    BookingFee = 998
                    TotalPrice = 998
                    OverallStatus = 'X'
                    CurrencyCode = 'INR'
                    BeginDate = cl_abap_context_info=>get_system_date( )
                    EndDate = cl_abap_context_info=>get_system_date(  ) + 3 ) )
     CREATE BY \_Booking FIELDS ( CarrierId ConnectionId CustomerId FlightDate FlightPrice )

* Here %cid_ref will be the GUID that will be created for the above trip , so that the connection between the two CDS

      WITH VALUE #( ( %cid_ref = 'V02'
                      %target = VALUE #( ( %cid = 'Booking'
                                           CarrierId =  '12'
                                           ConnectionId = '22'
                                           CustomerId = 'A001'
                                           FlightDate = cl_abap_context_info=>get_system_date(  )
                                           FlightPrice = 3900 ) ) ) )

      FAILED FINAL(lt_create_failed2)
      REPORTED FINAL(lt_create_reported2)
      MAPPED FINAL(lt_create_mapped2).

      COMMIT ENTITIES
      RESPONSE OF ZVK_TRAVEL_I
      FAILED DATA(lt_commit_failed2)
      REPORTED DATA(lt_commit_reported2).


      out->write( 'Case - 2 : New travel and booking record has been created ' ).

* Case - 2 - Creating the two travel records and 2 booking records for the first trip , and one booking record

       MODIFY ENTITY ZVK_TRAVEL_I
       CREATE
       FIELDS ( AgencyId Description BookingFee TotalPrice OverallStatus CurrencyCode BeginDate EndDate )
       WITH VALUE #( ( %cid = 'V03'
                       AgencyId = 'V03'
                       Description = 'New Agency Number V03'
                       BookingFee = 888
                       TotalPrice = 888
                       OverallStatus = 'B'
                       CurrencyCode = 'INR'
                       BeginDate = cl_abap_context_info=>get_system_date( )
                       EndDate = cl_abap_context_info=>get_system_date(  ) + 3 )

                       ( %cid = 'V04'
                         AgencyId = 'V04'
                         Description = 'New Agency Number V04'
                         BookingFee = 777
                         TotalPrice = 777
                         OverallStatus = 'C'
                         CurrencyCode = 'INR'
                         BeginDate = cl_abap_context_info=>get_system_date( )
                         EndDate = cl_abap_context_info=>get_system_date(  ) + 3 ) )

         CREATE BY \_Booking FIELDS ( CarrierId ConnectionId CustomerId FlightDate FlightPrice )

         WITH VALUE #( ( %cid_ref = 'V03'
                         %target = VALUE #( ( %cid = 'V03_Booking1'
                                              CarrierId =  '13'
                                              ConnectionId = '33'
                                              CustomerId = 'A002'
                                              FlightDate = cl_abap_context_info=>get_system_date(  )
                                              FlightPrice = 3901 )

                                              ( %cid = 'V03_Booking2'
                                              CarrierId =  '14'
                                              ConnectionId = '44'
                                              CustomerId = 'A003'
                                              FlightDate = cl_abap_context_info=>get_system_date(  )
                                              FlightPrice = 3902 ) ) )

                                              ( %cid_ref = 'V04'
                                                %target = VALUE #( ( %cid = 'V04_booking1'
                                                                     CarrierId =  '15'
                                                                     ConnectionId = '55'
                                                                     CustomerId = 'A004'
                                                                     FlightDate = cl_abap_context_info=>get_system_date(  )
                                                                     FlightPrice = 3903 ) ) ) )

          FAILED FINAL(lt_create_failed3)
          REPORTED FINAL(lt_create_reported3)
          MAPPED FINAL(lt_create_mapped3).

          COMMIT ENTITIES

          RESPONSE OF  ZVK_TRAVEL_I
          FAILED DATA(lt_commit_failed3)
          REPORTED DATA(lt_commit_reported3).

          out->write( 'Case - 3 : Travel and booking records are created' ).

* EML Update

  DATA : lt_update TYPE TABLE FOR UPDATE ZVK_TRAVEL_I.

  lt_update = VALUE #( ( TravelUuid = '7E5BF75F6D161FD180BC79432A262E69' CurrencyCode = 'USD' Description = 'Currency code has been changed ' BookingFee = 40 ) ).

  MODIFY ENTITIES OF ZVK_TRAVEL_I
  ENTITY Travel
  UPDATE
  FIELDS ( CurrencyCode Description BookingFee )
  WITH lt_update
  FAILED DATA(lt_failed_up)
  REPORTED DATA(lt_reported_up).

  COMMIT ENTITIES.

  out->write( 'Entity Updated successfully'  ).

* EML Delete

  DATA: lt_delete TYPE TABLE FOR DELETE ZVK_TRAVEL_I.

  lt_delete = VALUE #( ( TravelUuid = '7E5BF75F6D161FD180BC79432A26CE69 ' ) ).

  MODIFY ENTITIES OF ZVK_TRAVEL_I
  ENTITY Travel
* DELETE FROM VALUE #( ( TravelUuid = ' ' ) )
  DELETE FROM lt_delete
  FAILED DATA(lt_failed1)
  REPORTED DATA(lt_reported1).

  COMMIT ENTITIES
  RESPONSE OF ZVK_TRAVEL_I
  FAILED DATA(lt_commit_failed1)
  REPORTED DATA(lt_commit_reported1).



* EML READ
* Case 1 - In this case there is no FIELDS,Only the TravelUuid column is returned and the others will be empty

  READ ENTITIES OF ZVK_TRAVEL_I
  ENTITY Travel
  FROM VALUE #( ( TravelUuid = 'EE3D176152061FD0BFA03675AABBB1CD ' ) )  " V01
  RESULT DATA(lt_case1).

  out->write( 'READ operation without FIELDS keyword' ).


* Case 2 - With Fields , only 2 fields data is specified and only TravelUuid are brought

  READ ENTITIES OF ZVK_TRAVEL_I
  ENTITY Travel
  FIELDS ( TravelId AgencyId )
  WITH VALUE #( ( TravelUuid = 'EE3D176152061FD0BFA03675AABBB1CD ' ) )
  RESULT DATA(lt_case2).

  out->write( 'READ operation with FIELDS Keyword' ).


* Case 3 - With ALL FIELDS , If we want to bring all fields

  READ ENTITIES OF ZVK_TRAVEL_I
  ENTITY Travel
  ALL FIELDS WITH VALUE #( ( TravelUuid = 'EE3D176152061FD0BFA03675AABBB1CD ' ) )
  RESULT DATA(lt_case3).

  out->write( 'READ operation with ALL FIELDS keyword' ).

* Case 4 - Association using READ ( since Booking association is used , the reservation data for the Travel)

  READ ENTITIES OF ZVK_TRAVEL_I
  ENTITY Travel
  BY \_Booking
  ALL FIELDS WITH VALUE #( ( TravelUuid  = 'EE3D176152061FD0BFA03675AABBB1CD ' ) )
  RESULT DATA(lt_case4).

  out->write( 'READ operation with Booking association' ).


* Case 5 - If an attempt is made to be READ with an invalid GUID ( Only lt_failed is filled in )

  READ ENTITIES OF ZVK_TRAVEL_I
  ENTITY Travel
  ALL FIELDS WITH VALUE #( ( TravelUuid = 'EE3D176152061FD0BFA03675AABBB1CD ' ) )
  RESULT DATA(lt_case5)
  FAILED DATA(lt_failed5)
  REPORTED DATA(lt_reported5).

  out->write( 'Trying to read a record that does not exist' ).


    ENDMETHOD.


    METHOD simple_eml_form_create.
* EML Create and Declaration of data objects using BDEF derived types

    DATA : cr_tab TYPE TABLE FOR CREATE ZVK_TRAVEL_I,
           mapped_r TYPE RESPONSE FOR MAPPED ZVK_TRAVEL_I,
           failed_r TYPE RESPONSE FOR FAILED ZVK_TRAVEL_I,
           reported_r TYPE RESPONSE FOR REPORTED ZVK_TRAVEL_I.

    cr_tab = VALUE #( ( %cid = 'cid1'
                        TravelId = 1
                        AgencyId = 'AG01'
                        CustomerId = 'C01'
                        BookingFee = 1090
                        TotalPrice = 1090
                        CurrencyCode = 'USD'
                        Description = 'EML Create for Travel ID 1' )

                      ( %cid = 'cid2'   "Just to demo %data and %key you can specify fields with or without the derived type components

                        %data = VALUE #(  TravelId = 2
                                           AgencyId = 'AG02'
                                           CustomerId = 'C02'
                                           BookingFee = 1092
                                           TotalPrice = 1092
                                           CurrencyCode = 'USD'
                                           Description = 'EML Create for Travel ID 2' ) ) ).

* root_ent must be the full name of root entity , it is basically name of the BDEF

  MODIFY ENTITY  ZVK_TRAVEL_I
  CREATE "determines the kind of operation
  FIELDS ( AgencyId CustomerId BookingFee CurrencyCode Description ) WITH cr_tab " Fields to be respected for input derived type and the
                                                                                 " input derived type itself
  MAPPED mapped_r   "mapping info
  FAILED failed_r   "information on failures with instances
  REPORTED reported_r. "messages

  COMMIT ENTITIES.


    ENDMETHOD.
ENDCLASS.
