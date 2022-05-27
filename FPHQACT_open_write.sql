create or replace
Package Body     FPHQAUT IS
----------------------------------------------------------------------------------------------------------------------------
FUNCTION F_OPEN (f_name varchar2) return utl_file.file_type
IS
BEGIN
   DECLARE
      file_id        utl_file.file_type;
      intval         binary_integer;
      strval         varchar2(256);
      partyp         binary_integer;
      file_name      varchar2(30);
   BEGIN
      file_name := f_name;
      file_id:=utl_file.fopen('DIRLOG',file_name,'a');

      return file_id;

      EXCEPTION
         WHEN UTL_FILE.INVALID_PATH THEN
            RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
         WHEN UTL_FILE.INVALID_MODE THEN
            RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
         WHEN UTL_FILE.INVALID_FILEHANDLE THEN
            RAISE_APPLICATION_ERROR(-20102,'Invalid Filehandle');
         WHEN UTL_FILE.INVALID_OPERATION THEN
            RAISE_APPLICATION_ERROR(-20103,'Invalid Operation -- May signal a file locked by the OS');
         WHEN UTL_FILE.READ_ERROR THEN
            RAISE_APPLICATION_ERROR(-20104,'Read Error');
         WHEN UTL_FILE.WRITE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20105,'Write Error');
         WHEN UTL_FILE.INTERNAL_ERROR THEN
            RAISE_APPLICATION_ERROR(-20106,'Internal Error');
         WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20107,'No Data Found');
         WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20108,'Value Error');
         WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20109,sqlerrm);
   END;
END F_OPEN;
----------------------------------------------------------------------------------------------------------------------------
FUNCTION F_WRITE (f_id utl_file.file_type, v_msg varchar2) return number
IS
BEGIN
   BEGIN
      utl_file.put_line(f_id, v_msg);
      utl_file.fflush(f_id);
      return 0;
   END;
END F_WRITE;
----------------------------------------------------------------------------------------------------------------------------
FUNCTION F_OPEN_CVS (f_path varchar2,f_name varchar2, f_mode_open varchar2 DEFAULT 'a') return utl_file.file_type
IS
BEGIN
   DECLARE
      file_id        utl_file.file_type;
      intval         binary_integer;
      strval         varchar2(256);
      partyp         binary_integer;
      file_name      varchar2(100);
   BEGIN
      file_name := f_name;
      STRVAL    := F_PATH;
      file_id:=utl_file.fopen(strval,file_name,f_mode_open, 32767);

      return file_id;

      EXCEPTION
         WHEN UTL_FILE.INVALID_PATH THEN
            RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
         WHEN UTL_FILE.INVALID_MODE THEN
            RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
         WHEN UTL_FILE.INVALID_FILEHANDLE THEN
            RAISE_APPLICATION_ERROR(-20102,'Invalid Filehandle');
         WHEN UTL_FILE.INVALID_OPERATION THEN
            RAISE_APPLICATION_ERROR(-20103,'Invalid Operation -- May signal a file locked by the OS');
         WHEN UTL_FILE.READ_ERROR THEN
            RAISE_APPLICATION_ERROR(-20104,'Read Error');
         WHEN UTL_FILE.WRITE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20105,'Write Error');
         WHEN UTL_FILE.INTERNAL_ERROR THEN
            RAISE_APPLICATION_ERROR(-20106,'Internal Error');
         WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20107,'No Data Found');
         WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20108,'Value Error');
         WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20109,sqlerrm);
   END;
END F_OPEN_CVS;
-------------------------------------------------------------------------------------
FUNCTION F_OPEN_CVS_UTF8 (f_path varchar2,f_name varchar2) return utl_file.file_type
IS
BEGIN
   DECLARE
      file_id        utl_file.file_type;
      intval         binary_integer;
      strval         varchar2(256);
      partyp         binary_integer;
      file_name      varchar2(30);
   BEGIN
      file_name := f_name;
      file_id:=UTL_FILE.FOPEN_NCHAR(f_path, file_name, 'a', 32767);

      return file_id;

      EXCEPTION
         WHEN UTL_FILE.INVALID_PATH THEN
            RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
         WHEN UTL_FILE.INVALID_MODE THEN
            RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
         WHEN UTL_FILE.INVALID_FILEHANDLE THEN
            RAISE_APPLICATION_ERROR(-20102,'Invalid Filehandle');
         WHEN UTL_FILE.INVALID_OPERATION THEN
            RAISE_APPLICATION_ERROR(-20103,'Invalid Operation -- May signal a file locked by the OS');
         WHEN UTL_FILE.READ_ERROR THEN
            RAISE_APPLICATION_ERROR(-20104,'Read Error');
         WHEN UTL_FILE.WRITE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20105,'Write Error');
         WHEN UTL_FILE.INTERNAL_ERROR THEN
            RAISE_APPLICATION_ERROR(-20106,'Internal Error');
         WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20107,'No Data Found');
         WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20108,'Value Error');
         WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20109,sqlerrm);
   END;
END F_OPEN_CVS_UTF8;
-------------------------------------------------------------------------------------
FUNCTION F_WRITE_CVS (f_id utl_file.file_type, v_msg varchar2) return number
IS
BEGIN
   BEGIN
      utl_file.put_line(f_id, v_msg);
      utl_file.fflush(f_id);
      return 0;
   END;
END F_WRITE_CVS;
----------------------------------------------------------------------------------------
FUNCTION F_WRITE_CVS_UTF8 (f_id utl_file.file_type, v_msg varchar2) return number
IS
text_raw RAW(32767);
BEGIN
   BEGIN
      text_raw := UTL_I18N.STRING_TO_RAW(v_msg, 'UTF8');
      UTL_FILE.PUT_NCHAR(f_id, UTL_I18N.RAW_TO_NCHAR(text_raw, 'UTF8'));
      utl_file.new_line(f_id);
      return 0;
   END;
END F_WRITE_CVS_UTF8;
----------------------------------------------------------------------------------------
FUNCTION CALCUL_DELAI_DEC (v_date_arriv date ,v_date_dec1 date ,v_pays varchar2) return number
IS
BEGIN
   DECLARE

    V_DE_HD_DTREAL_ARRIV_CALC date;
    V_DE_HD_DTREAL_DEC1_CALC  date;
    V_DE_OD_DELAIDEC number;
    CURSOR CUR_CAL IS
        select DA_AN_JOUR,
              DA_AN_CDPAYS,
              DA_AN_ANNEE,
              DA_AN_SEMAINE,
              DA_AN_HROUVERT,
              DA_AN_HRFERME,
              DA_AN_FLGOUVERT
       from FPHTDB.TDB_CALEND
       where (DA_AN_JOUR between trunc(v_date_arriv) and trunc(v_date_dec1))
         and DA_AN_CDPAYS = v_pays
       order by DA_AN_JOUR;

   BEGIN

      -- calcul du delai de decision :
      -- pour une demande donnee, la precision sur le delai de decision est la seconde.
      -- pour calculer le delai de decision, il faut calculer le nombre de secondes entre
      -- la date d arrivee dans la gp et la date de la premiere decision auquel on retire
      -- le temps non travaill? entre les deux dates (en tenant compte des heures
      -- d ouvertures/fermetures de la SF et des jours non travailles).

           V_DE_OD_DELAIDEC := 0;
           --il faut selectionner les jours du calendrier compris entre les deux dates
           for rec_cal in CUR_CAL
           loop
              -------------------------------------------------------------------
              -- il faut recadrer les heures d arrivee et de decision si elles
              -- sont hors des heures d ouvertures
              -------------------------------------------------------------------
              if ((rec_cal.DA_AN_FLGOUVERT = 'O') and (trunc(v_date_arriv) = rec_cal.DA_AN_JOUR)) then
                if v_date_arriv <= rec_cal.DA_AN_HROUVERT
                   then V_DE_HD_DTREAL_ARRIV_CALC := rec_cal.DA_AN_HROUVERT;
                elsif v_date_arriv >= rec_cal.DA_AN_HRFERME
                   then V_DE_HD_DTREAL_ARRIV_CALC := rec_cal.DA_AN_HRFERME;
                else V_DE_HD_DTREAL_ARRIV_CALC := v_date_arriv;
                end if;
              end if;
              -------------------------------------------------------------------
              if ((rec_cal.DA_AN_FLGOUVERT = 'O') and (trunc(v_date_dec1) = rec_cal.DA_AN_JOUR)) then
                if v_date_dec1 <= rec_cal.DA_AN_HROUVERT
                   then V_DE_HD_DTREAL_DEC1_CALC := rec_cal.DA_AN_HROUVERT;
                elsif v_date_dec1 >= rec_cal.DA_AN_HRFERME
                   then V_DE_HD_DTREAL_DEC1_CALC := rec_cal.DA_AN_HRFERME;
                else V_DE_HD_DTREAL_DEC1_CALC := v_date_dec1;
                end if;
              end if;
              -------------------------------------------------------------------


             if rec_cal.DA_AN_FLGOUVERT = 'O' then
                if trunc(v_date_dec1) = trunc(v_date_arriv) then
                ----------------------------------------------------------------------------------
                  V_DE_OD_DELAIDEC := to_number(to_char(V_DE_HD_DTREAL_DEC1_CALC,'SSSSS'))
                                    - to_number(to_char(V_DE_HD_DTREAL_ARRIV_CALC,'SSSSS'));
                ----------------------------------------------------------------------------------
                else
                ----------------------------------------------------------------------------------
                  if trunc(v_date_arriv) = rec_cal.DA_AN_JOUR then
                       V_DE_OD_DELAIDEC := V_DE_OD_DELAIDEC +
                                           + to_number(to_char(rec_cal.DA_AN_HRFERME,'SSSSS'))
                                           - to_number(to_char(V_DE_HD_DTREAL_ARRIV_CALC,'SSSSS'));
                  elsif trunc(v_date_dec1) = rec_cal.DA_AN_JOUR then
                          V_DE_OD_DELAIDEC := V_DE_OD_DELAIDEC +
                                           + to_number(to_char(V_DE_HD_DTREAL_DEC1_CALC,'SSSSS'))
                                           - to_number(to_char(rec_cal.DA_AN_HROUVERT,'SSSSS'));
                  else
                          V_DE_OD_DELAIDEC := V_DE_OD_DELAIDEC
                                           + to_number(to_char(rec_cal.DA_AN_HRFERME,'SSSSS'))
                                           - to_number(to_char(rec_cal.DA_AN_HROUVERT,'SSSSS'));
                  end if;
                ----------------------------------------------------------------------------------
                end if;
             end if;

           end loop;

       return V_DE_OD_DELAIDEC;
   EXCEPTION
      when others then
       V_DE_OD_DELAIDEC := -1;
       return V_DE_OD_DELAIDEC;

   END;


END CALCUL_DELAI_DEC;

FUNCTION F_OPEN_XML (f_name varchar2) return utl_file.file_type
IS
BEGIN
   DECLARE
      file_id        utl_file.file_type;
      intval         binary_integer;
      strval         varchar2(256);
      partyp         binary_integer;
      file_name      varchar2(30);
   BEGIN
      file_name := f_name;
      partyp    := dbms_utility.get_parameter_value('utl_file_dir', intval, strval);
      file_id   := utl_file.FOPEN_NCHAR(strval,file_name,'w');

      return file_id;

      EXCEPTION
         WHEN UTL_FILE.INVALID_PATH THEN
            RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
         WHEN UTL_FILE.INVALID_MODE THEN
            RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
         WHEN UTL_FILE.INVALID_FILEHANDLE THEN
            RAISE_APPLICATION_ERROR(-20102,'Invalid Filehandle');
         WHEN UTL_FILE.INVALID_OPERATION THEN
            RAISE_APPLICATION_ERROR(-20103,'Invalid Operation -- May signal a file locked by the OS');
         WHEN UTL_FILE.READ_ERROR THEN
            RAISE_APPLICATION_ERROR(-20104,'Read Error');
         WHEN UTL_FILE.WRITE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20105,'Write Error');
         WHEN UTL_FILE.INTERNAL_ERROR THEN
            RAISE_APPLICATION_ERROR(-20106,'Internal Error');
         WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20107,'No Data Found');
         WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR(-20108,'Value Error');
         WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20109,sqlerrm);
   END;
END F_OPEN_XML;

END FPHQAUT;
