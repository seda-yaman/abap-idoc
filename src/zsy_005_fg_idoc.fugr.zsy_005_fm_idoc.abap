FUNCTION zsy_005_fm_idoc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_KUNNR) TYPE  KNA1-KUNNR
*"  EXPORTING
*"     REFERENCE(ES_EXPORT) TYPE  ZSY_005_S_IDOC
*"----------------------------------------------------------------------

    DATA: lt_edidd TYPE TABLE OF edidd,
          lt_edidc TYPE TABLE OF edidc.

    CLEAR : lt_edidc, lt_edidd.

  SELECT SINGLE name1,
                ort02,
                stras,
                ort01,
                regio,
                land1
    FROM kna1
    INTO CORRESPONDING FIELDS OF @es_export
    WHERE kunnr EQ @iv_kunnr.


  DATA(ls_edidc) = VALUE edidc( mestyp = 'ZSY_IDOC_TS'
                                doctyp = 'ZSY_IDOC'
                                rcvprn = 'S4HCLNT500'
                                rcvprt = 'LS' ).

      APPEND INITIAL LINE TO lt_edidd ASSIGNING FIELD-SYMBOL(<fs_edidd>).
      <fs_edidd>-segnam = 'ZSY_IDOC'.
      <fs_edidd>-sdata  = |{ es_export-name1 }{ es_export-ort02 }{ es_export-stras }{ es_export-ort01 }{ es_export-regio }{ es_export-land1 }|.

  CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
    EXPORTING
      master_idoc_control            = ls_edidc
*     OBJ_TYPE                       = ''
*     CHNUM                          = ''
    TABLES
      communication_idoc_control     = lt_edidc
      master_idoc_data               = lt_edidd
    EXCEPTIONS
      error_in_idoc_control          = 1
      error_writing_idoc_status      = 2
      error_in_idoc_data             = 3
      sending_logical_system_unknown = 4
      OTHERS                         = 5.

  IF sy-subrc EQ 0.

    CALL FUNCTION 'DB_COMMIT'.
    CALL FUNCTION 'DEQUEUE_ALL'.
    COMMIT WORK.

  ENDIF.


ENDFUNCTION.
