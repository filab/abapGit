*&---------------------------------------------------------------------*
*& Include zabapgit_object_cus0
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_object_cus0 DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_object_cus0 DEFINITION INHERITING FROM lcl_objects_super FINAL.

  PUBLIC SECTION.
    INTERFACES lif_object.
    ALIASES mo_files FOR lif_object~mo_files.

    METHODS constructor
      IMPORTING
        is_item     TYPE zif_abapgit_definitions=>ty_item
        iv_language TYPE spras.

  PRIVATE SECTION.
    TYPES: tty_img_activity_texts TYPE STANDARD TABLE OF cus_imgact
                                       WITH NON-UNIQUE DEFAULT KEY,
           BEGIN OF ty_img_activity,
             header TYPE cus_imgach,
             texts  TYPE tty_img_activity_texts,
           END OF ty_img_activity.
    DATA: mv_img_activity TYPE cus_img_ac.

ENDCLASS.                    "lcl_object_cus0 DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_object_cus0 IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_object_cus0 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( is_item = is_item
                        iv_language = iv_language ).

    mv_img_activity = ms_item-obj_name.

  ENDMETHOD.                    "constructor

  METHOD lif_object~has_changed_since.
    rv_changed = abap_true.
  ENDMETHOD.  "lif_object~has_changed_since

  METHOD lif_object~changed_by.
    rv_user = c_user_unknown.
  ENDMETHOD.

  METHOD lif_object~get_metadata.
    rs_metadata = get_metadata( ).
  ENDMETHOD.                    "lif_object~get_metadata

  METHOD lif_object~jump.

    zcx_abapgit_exception=>raise( |TODO: Jump| ).

*   doesn't work...
*    CALL FUNCTION 'S_CUS_IMG_ACTIVITY_MAINTAIN'
*      EXPORTING
*        i_display        = 'X'
*        i_no_replacement = 'X'
*      CHANGING
*        img_activity     = mv_img_activity.

  ENDMETHOD.                    "jump

  METHOD lif_object~exists.

    DATA: ls_message TYPE hier_mess.

    CALL FUNCTION 'S_CUS_IMG_ACTIVITY_EXISTS'
      EXPORTING
        img_activity = mv_img_activity
      IMPORTING
        message      = ls_message.

    rv_bool = boolc( ls_message IS INITIAL ).

  ENDMETHOD.                    "lif_object~exists

  METHOD lif_object~delete.

    DATA: ls_message TYPE hier_mess.

    CALL FUNCTION 'S_CUS_IMG_ACTIVITY_DELETE'
      EXPORTING
        img_activity = mv_img_activity
      IMPORTING
        message      = ls_message.

    IF ls_message-msgty <> 'S'.
      zcx_abapgit_exception=>raise( |error from delete CUS0 { mv_img_activity } S_CUS_IMG_ACTIVITY_DELETE| ).
    ENDIF.

  ENDMETHOD.                    "delete

  METHOD lif_object~serialize.

    DATA: ls_img_activity TYPE ty_img_activity.

    CALL FUNCTION 'S_CUS_IMG_ACTIVITY_READ'
      EXPORTING
        img_activity        = mv_img_activity
      IMPORTING
        img_activity_header = ls_img_activity-header
      TABLES
        img_activity_texts  = ls_img_activity-texts.

    CLEAR: ls_img_activity-header-fuser,
           ls_img_activity-header-fdate,
           ls_img_activity-header-ftime,
           ls_img_activity-header-luser,
           ls_img_activity-header-ldate,
           ls_img_activity-header-ltime.

    io_xml->add( iv_name = 'CUS0'
                 ig_data = ls_img_activity ).

  ENDMETHOD.                    "serialize

  METHOD lif_object~deserialize.

    DATA: ls_img_activity TYPE ty_img_activity,
          ls_text         LIKE LINE OF ls_img_activity-texts.

    io_xml->read(
      EXPORTING
        iv_name = 'CUS0'
      CHANGING
        cg_data = ls_img_activity ).

    READ TABLE ls_img_activity-texts INTO ls_text
                                     WITH KEY spras = sy-langu.

    CALL FUNCTION 'S_CUS_IMG_ACTIVITY_SAVE'
      EXPORTING
        img_activity  = ls_img_activity-header-activity
        i_docu        = ls_img_activity-header-docu_id
        i_attributes  = ls_img_activity-header-attributes
        i_activity    = ls_img_activity-header-c_activity
        i_description = ls_text
        i_tcode       = ls_img_activity-header-tcode.

  ENDMETHOD.                    "deserialize

  METHOD lif_object~compare_to_remote_version.
    CREATE OBJECT ro_comparison_result TYPE lcl_comparison_null.
  ENDMETHOD.

ENDCLASS.                    "lcl_object_cus0 IMPLEMENTATION