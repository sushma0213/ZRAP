
CLASS lhc_yi_booking_tech_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE yi_booking_tech_m\_Bookingsuppl.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR yi_booking_tech_m RESULT result.

    METHODS validateconnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR yi_booking_tech_m~validateconnection.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR yi_booking_tech_m~validatecurrencycode.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR yi_booking_tech_m~validatecustomer.

    METHODS validateflightprice FOR VALIDATE ON SAVE
      IMPORTING keys FOR yi_booking_tech_m~validateflightprice.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR yi_booking_tech_m~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR yi_booking_tech_m~calculatetotalprice.

ENDCLASS.

CLASS lhc_yi_booking_tech_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA: max_booking_suppl_id TYPE /dmo/booking_supplement_id .

    READ ENTITIES OF yi_travel_tech_m IN LOCAL MODE
      ENTITY yi_booking_tech_m  BY \_Bookingsuppl
        FROM CORRESPONDING #( entities )
        LINK DATA(booking_supplements).

    " Loop over all unique tky (TravelID + BookingID)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>) GROUP BY <booking_group>-%tky.

      " Get highest bookingsupplement_id from bookings belonging to booking
      max_booking_suppl_id = REDUCE #( INIT max = CONV /dmo/booking_supplement_id( '0' )
                                       FOR  booksuppl IN booking_supplements USING KEY entity
                                                                             WHERE (     source-TravelId  = <booking_group>-TravelId
                                                                                     AND source-BookingId = <booking_group>-BookingId )
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   booksuppl-target-BookingSupplementId > max
                                                                          THEN booksuppl-target-BookingSupplementId
                                                                          ELSE max )
                                     ).
      " Get highest assigned bookingsupplement_id from incoming entities
      max_booking_suppl_id = REDUCE #( INIT max = max_booking_suppl_id
                                       FOR  entity IN entities USING KEY entity
                                                               WHERE (     TravelId  = <booking_group>-TravelId
                                                                       AND BookingId = <booking_group>-BookingId )
                                       FOR  target IN entity-%target
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   target-BookingSupplementId > max
                                                                                     THEN target-BookingSupplementId
                                                                                     ELSE max )
                                     ).


      " Loop over all entries in entities with the same TravelID and BookingID
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity WHERE TravelId  = <booking_group>-TravelId
                                                                            AND BookingId = <booking_group>-BookingId.

        " Assign new booking_supplement-ids
        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_numbers>).
          APPEND CORRESPONDING #( <booksuppl_wo_numbers> ) TO mapped-yi_booksuppl_tech_m ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).
          IF <booksuppl_wo_numbers>-BookingSupplementId IS INITIAL.
            max_booking_suppl_id += 1 .
            <mapped_booksuppl>-BookingSupplementId = max_booking_suppl_id .
          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF yi_travel_tech_m IN LOCAL MODE
     ENTITY yi_travel_tech_m BY \_Booking
     FIELDS ( TravelId BookingStatus )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_booking).

    result  = VALUE #( FOR ls_booking IN lt_booking
                        (  %tky = ls_booking-%tky
                           %features-%assoc-_Bookingsuppl  = COND #( WHEN ls_booking-BookingStatus = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                                                                     )
                   ).




  ENDMETHOD.

  METHOD validateConnection.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA: it_travel TYPE STANDARD TABLE OF yi_travel_tech_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    it_travel =  CORRESPONDING #(  keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).
    MODIFY ENTITIES OF yi_travel_tech_m IN LOCAL MODE
     ENTITY yi_travel_tech_m
     EXECUTE recalcTotPrice
     FROM CORRESPONDING #( it_travel ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
