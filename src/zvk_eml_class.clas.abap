CLASS zvk_eml_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .


  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS zvk_eml_class IMPLEMENTATION.

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
                    AgencyId = 'V01'
                    Description = 'New Agency Number V01'
                    BookingFee = 999
                    TotalPrice = 999
                    OverallStatus = 'A'
                    CurrencyCode = 'INR'
                    BeginDate = cl_abap_context_info=>get_system_date( )
                    EndDate = cl_abap_context_info=>get_system_date(  ) + 3 ) )
     CREATE BY \_Booking FIELDS ( CarrierId ConnectionId CustomerId FlightDate FlightPrice )

* Here %cid_ref will be the GUID that will be created for the above trip , so that the connection between the two CDS

      WITH VALUE #( ( %cid_ref = 'V02'
                      %target = VALUE #( ( %cid = 'Booking' ) ) ) ).











    ENDMETHOD.
ENDCLASS.
