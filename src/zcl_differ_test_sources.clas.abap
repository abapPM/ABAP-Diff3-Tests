CLASS zcl_differ_test_sources DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

************************************************************************
* ABAP Differ - Test for Diffing ABAP Source Code
*
* Copyright 2021 Marc Bernard <https://marcbernardtools.com/>
* SPDX-License-Identifier: MIT
************************************************************************
  PUBLIC SECTION.

    CLASS-METHODS get_delta_diff3
      IMPORTING
        !it_new         TYPE abaptxt255_tab
        !it_old         TYPE abaptxt255_tab
      RETURNING
        VALUE(rt_delta) TYPE vxabapt255_tab.

    CLASS-METHODS get_delta_sap
      IMPORTING
        !it_new         TYPE abaptxt255_tab
        !it_old         TYPE abaptxt255_tab
      RETURNING
        VALUE(rt_delta) TYPE vxabapt255_tab.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_differ_test_sources IMPLEMENTATION.


  METHOD GET_DELTA_DIFF3.

    DATA:
      lt_buffer1 TYPE string_table,
      lt_buffer2 TYPE string_table,
      li_diff3   TYPE REF TO zif_differ_diff3,
      ls_delta   LIKE LINE OF rt_delta.

    LOOP AT it_old ASSIGNING FIELD-SYMBOL(<ls_code>).
      INSERT |{ <ls_code>-line }| INTO TABLE lt_buffer1.
    ENDLOOP.

    LOOP AT it_new ASSIGNING <ls_code>.
      INSERT |{ <ls_code>-line }| INTO TABLE lt_buffer2.
    ENDLOOP.

    CREATE OBJECT li_diff3 TYPE zcl_differ_diff3.

    DATA(lt_diffs) = li_diff3->diff_indices(
      it_buffer1 = lt_buffer1
      it_buffer2 = lt_buffer2 ).

    zcl_differ_diff3=>convert_to_abap_indices( CHANGING ct_diff_indices = lt_diffs ).

    LOOP AT lt_diffs ASSIGNING FIELD-SYMBOL(<ls_diff>).
      CLEAR ls_delta.
      IF <ls_diff>-buffer1-len > 0 AND <ls_diff>-buffer2-len > 0.
        ls_delta-vrsflag = zif_abapgit_definitions=>c_diff-update.
        ls_delta-number  = <ls_diff>-buffer1-key.
        ls_delta-line    = <ls_diff>-buffer1content[ 1 ].
      ELSEIF <ls_diff>-buffer1-len > 0.
        ls_delta-vrsflag = zif_abapgit_definitions=>c_diff-delete.
        ls_delta-number  = <ls_diff>-buffer1-key.
        ls_delta-line    = <ls_diff>-buffer1content[ 1 ].
      ELSEIF <ls_diff>-buffer2-len > 0.
        ls_delta-vrsflag = zif_abapgit_definitions=>c_diff-insert.
        ls_delta-number  = <ls_diff>-buffer2-key.
        ls_delta-line    = <ls_diff>-buffer2content[ 1 ].
      ELSE.
        ASSERT 0 = 1.
      ENDIF.
      INSERT ls_delta INTO TABLE rt_delta.
    ENDLOOP.

  ENDMETHOD.


  METHOD GET_DELTA_SAP.

    DATA:
      lt_trdirtab_old TYPE TABLE OF trdir,
      lt_trdirtab_new TYPE TABLE OF trdir,
      lt_trdir_delta  TYPE TABLE OF xtrdir.

    CALL FUNCTION 'SVRS_COMPUTE_DELTA_REPS'
      TABLES
        texttab_old  = it_old
        texttab_new  = it_new
        trdirtab_old = lt_trdirtab_old
        trdirtab_new = lt_trdirtab_new
        trdir_delta  = lt_trdir_delta
        text_delta   = rt_delta.

  ENDMETHOD.
ENDCLASS.
