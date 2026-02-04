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

ENDCLASS.
