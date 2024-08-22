CLASS ycl_DATA_GENERATOR DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS YCL_DATA_GENERATOR IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " delete existing entries in the database table
    DELETE FROM ytravel_tech_m.
    DELETE FROM yBOOKING_tech_m.
    DELETE FROM ybooksupp_tech_m.
    COMMIT WORK.
    " insert travel demo data
    INSERT ytravel_tech_m FROM (
        SELECT *
          FROM /dmo/travel_m
      ).
    COMMIT WORK.

    " insert booking demo data
    INSERT ybooking_tech_m FROM (
        SELECT *
          FROM   /dmo/booking_m
*            JOIN ytravel_tech_m AS y
*            ON   booking~travel_id = y~travel_id

      ).
    COMMIT WORK.
    INSERT ybooksupp_tech_m FROM (
        SELECT *
          FROM   /dmo/booksuppl_m
*            JOIN ytravel_tech_m AS y
*            ON   booking~travel_id = y~travel_id

      ).
    COMMIT WORK.

    out->write( 'Travel and booking demo data inserted.' ).


  ENDMETHOD.
ENDCLASS.
