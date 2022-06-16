create or replace PACKAGE BODY FPHQACT2 AS

  FUNCTION ALIM_DONNEES_FPHQT2_ES (NOMLOG      VARCHAR2,
                                  P_DATE_TRAI   DATE,
                                  V_INSERTS     OUT NUMBER,
                                  V_UPDATES     OUT NUMBER,
                                  V_ERROR       OUT VARCHAR2) RETURN NUMBER IS
  begin
  declare
       P_DATE_SITU          date;
      V_ERR                NUMBER := 0;
      V_INS                NUMBER := 0;
      V_UPD                NUMBER := 0;
      FILE_ID              UTL_FILE.FILE_TYPE;
      RES                  NUMBER := 0;
      V_NOM_TRAIT          VARCHAR2(50) := 'ALIM_DONNEES_FPHQT2_ES';
      V_CODE_PAYS          VARCHAR2(2);
    
      val_ecart_km  NUMBER;
     

        
        CURSOR C_FDHT_ALIM IS  

select
  to_date(Sysdate, 'DD/MM/YYYY') As Date_Traitement,  --Date_de_Traitement
T90.PY_CD_PAYS  AS   CD_PAYS ,
'EKIP'  AS   CD_SOURCE ,
T90.ID_RESEAU  AS   RESEAU ,
T90.IE_AFFAIRE  AS   CTR_NUM_1 ,
T90.IE_AFFAIRE  AS   CTR_NUM_2 ,
NULL  AS   BUY_BACK_TYPE ,
CLIE.NIF  CL_SIREN,  -- FPHQTTI.NIF  AS   CL_SIREN ,
CLIE.NOM  CL_NOM , -- FPHQTTI.NOM  AS   CL_NOM ,
NULL  AS   TVA_CD ,
CLIE.TYPE_SEGMENT  CL_TYP_LIB, -- FPHQTTI.TYPE_SEGMENT  AS   CL_TYP_LIB ,
CLIE.CODE_APE  CL_APE_CD, -- FPHQTTI.CODE_APE  AS   CL_APE_CD ,
CLIE.SECT_ACTIVITE    CL_APE_LIB, --FPHQTTI.SECT_ACTIVITE  AS   CL_APE_LIB ,
CONCAT(PCLI.ANC_NO_RUE,concat(' ',PCLI.ANC_NOM_RUE))  CL_ADR_FACT, -- CONCAT(FPHQTTI.ANC_NO_RUE,' ',FPHQTTI.ANC_NOM_RUE) as CL_ADR_FACT, 
PCLI.ANC_CODE_POSTAL  CL_ADR_CP,  -- FPHQTTI.ANC_CODE_POSTAL  AS   CL_ADR_CP ,
PCLI.ANC_LOCALITE  CL_ADR_VILLE, --FPHQTTI.ANC_LOCALITE  AS   CL_ADR_VILLE ,
NULL  AS   CTR_RETAIL ,
FPHQTCL.CL_IN_IDTITRE   CIVILITE_SIGNATAIRE, --FPHQTCL.CL_IN_IDTITRE (CD avec jointure sur table LIB : FNMVTI0)  AS   CIVILITE_SIGNATAIRE ,   ------ ### ON ATTEND LES INFO 
FPHQTCL.CL_RE_NOM1   NOM_SIGNATAIRE , --FPHQTCL.CL_RE_NOM1  AS   NOM_SIGNATAIRE ,
FPHQTCL.CL_RE_PRNOM   PRENOM_SIGNATAIRE , --FPHQTCL.CL_RE_PRNOM  AS   PRENOM_SIGNATAIRE ,
CLIE.TELEPHONE  TEL_CONTACT,  -- FPHQTTI.TELEPHONE  AS   TEL_CONTACT ,
CLIE.EMAIL  EMAIL_SIGNATAIRE, -- FPHQTTI.EMAIL AS   EMAIL_SIGNATAIRE ,
FPHQT91.DUREE_TOT_I  AS   DUREE_INI ,
T90.KM_CONTRACTUEL_INI  AS   KM_PIVOT_INI ,
T90.MT_VR_I  AS   ER_PIVOT_INI ,
T90.DATE_MEL_FIN  AS   CTR_DT_FIN ,
NULL  AS   CTR_DMIN_B2 ,
NULL  AS   CTR_DMIN_B1 ,
FPHQT91.DUREE_TOT  AS   CTR_DTOT ,
NULL  AS   CTR_DMAX_B1 ,
NULL  AS   CTR_DMAX_B2 , 
T90.BORNE_KM_INF_2  AS   CTR_KMIN_B2 ,
T90.BORNE_KM_INF_1  AS   CTR_KMIN_B1 ,
T90.KM_CONTRACTUEL   AS   CTR_KM_PIVOT ,
T90.BORNE_KM_SUPP_1  AS   CTR_KMAX_B1 ,
T90.BORNE_KM_SUPP_2  AS   CTR_KMAX_B2 ,
NULL  AS   CTR_ERMIN_B2 ,
NULL  AS   CTR_ERMIN_B1 ,
T90.MT_VR  AS   CTR_ER_HT ,
NULL  AS   CTR_ERMAX_B1 ,
NULL  AS   CTR_ERMAX_B2 ,
FPHQTVB.VB_KM_REL  GIFP_DER_KM,  -- FPHQTVB.VB_KM_REL  AS   GIFP_DER_KM ,
FPHQTVB.VB_DT_RELKM   GIFP_DT_DER_KM, ---  FPHQTVB.VB_DT_RELKM  AS   GIFP_DT_DER_KM ,
FPHQTVB.VB_CD_SRCEVT  GIFP_ORIG_DER_KM, -- FPHQTVB.VB_CD_SRCEVT  AS   GIFP_ORIG_DER_KM ,


NVL(Fphqtvb.Vb_Km_Rel, '0') * NVL(t90.KM_CONTRACTUEL, '0') / Months_Between(Sysdate, to_date(t90.Date_Megd, 'DD/MM/YYYY')) as GIFP_PROJ_KM_FCT,
/*
-----------------
CASE CTR_KM_PIVOT WHEN 0 THEN  null
                WHEN NULL then null
                else case GIFP_PROJ_KM_FCT when 0 then  null
                                          when null then null
                                          else case (NVL(GIFP_PROJ_KM_FCT,'0') - NVL(CTR_KM_PIVOT,'0')) when 0 then  null
                                                                                                      else (GIFP_PROJ_KM_FCT - CTR_KM_PIVOT) end  end  end  v_ecart_km,     
------------------
*/
NULL  AS   CTR_TYP_SOUP ,
NULL  AS   REDEV_KM_EXCED ,
FPHQT91.MT_LOYER_TOT_HT  AS   LOY_MTHT_FIN ,
NVL(FPHQT91.MT_HT_ECH,'0') + NVL(FPHQT91.MT_HT_SERV,'0')  AS   LOY_MT_HT ,
NVL(FPHQT91.MT_TTC_ECH,'0') + NVL(FPHQT91.MT_TTC_SERV,'0')  AS   LOY_MT_TTC ,
NULL  AS   LOY_FLG_GPF ,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO = 'MNT' AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end  LOY_FLG_MAIN ,  -- FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS 
NULL  AS   LOY_PCT_CEM ,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO = 'ATR' AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end LOY_FLG_TR, --  FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS   LOY_FLG_TR ,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO IN ('ASP', 'ASR', 'AST') AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end LOY_FLG_ASS,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO = 'KUA' AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end  LOY_FLG_IP, --FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS   LOY_FLG_IP ,
NULL  AS   LOY_FLG_AFD ,
Null  As   Loy_Flg_Carbu ,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO = 'PNE' AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end FLAG_PNEUS_ETE, --FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS   FLAG_PNEUS_ETE ,
Case  When Exists (Select 1 From Fph.Fphqt92 T92 Where Code_Type_Service_Bo = 'PNH' And T92.Ie_Affaire = T90.Ie_Affaire) Then 'OUI'  Else 'NON' End  Flag_Pneus_Hiver, --FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS   FLAG_PNEUS_HIVER ,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO = 'VRE' AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end FLAG_VEHICULE_DE_REMPLACEMENT, --FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS   FLAG_VEHICULE_DE_REMPLACEMENT ,
NULL  AS   FLAG_CEM_FLEX ,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO = 'PN4' AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end FLAG_PNEU_MIXTE, --FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS   FLAG_PNEU_MIXTE ,
NULL  AS   FLAG_JOCKEY ,
CASE  WHEN EXISTS (SELECT 1 FROM FPH.FPHQT92 T92 WHERE CODE_TYPE_SERVICE_BO = 'PAR' AND T92.IE_AFFAIRE = T90.IE_AFFAIRE) THEN 'OUI'  ELSE 'NON' end FLAG_PASS_RESTIT,-- FPHQT92.Si Presence d'une ligne alors 'OUI' sinon 'NON'  AS   FLAG_PASS_RESTIT ,
FPHQTFV.FV_CD_FAM_VEHICULE  AS   VEH_FAM , ------------------------------------------   AJOUTER APRES CAR FPHQTFV VIDE : FPHQTFV.FV_CD_FAM_VEHICULE  AS   VEH_FAM ,
FPHQTFV.FV_LIB_FAM_VEHICULE  AS   VEH_LIB_LS ,
T90.CODE_PSA  AS   VEH_LCDV ,
T90.LIB_COMMERCIAL  AS   VEH_LCDV_LIB ,
NULL  AS   CARROSSERIE ,
NULL  AS   VEH_COUL ,
T90.CODE_GENRE  AS   VEH_GENRE ,
T90.ENERGIE  AS   VEH_NRJ ,
T90.EMISSION_CO2  AS   VEH_CO2 ,
T90.PUISSANCE  AS   VEH_PUIS_FISC ,
T90.VIN  AS   VEH_TYP_MINE ,
T90.VIN  AS   VEH_NO_SERIE ,
NULL AS VEH_BLVD, -------------------------- FPHQT90.CODE_BLVD  AS   VEH_BLVD , ---------------------- A AJOUTER QUAND L'INFO SERA DISPONIBLE
FPHQT91.IMMATRICULATION  AS   VEH_NO_IMMAT ,
T90.DATE_LIVRAISON  AS   CTR_DT_LIV ,
CHAU.NOM  NOM_CHAUFFEUR , -- FPHQTTI.NOM  AS   NOM_CHAUFFEUR ,
T90.CODE_GENRE  AS   GENRE_CD_TRANSCO ,
T90.MT_CATALOGUE  AS   VEH_MTHT_CAT ,
T90.MT_OPTIONS  AS   VEH_MTHT_OPT ,
T90.POURC_REMISE  AS   VEH_PCT_REM ,
T90.MT_ACCESSOIRES  AS   VEH_MTHT_ACC ,
NULL  AS   VEH_MTHT_TRANS ,
NULL  AS   VEH_GARN ,
NULL  AS   VEH_OPT1 ,
NULL  AS   VEH_OPT2 ,
NULL  AS   VEH_OPT3 ,
NULL  AS   VEH_OPT4 ,
NULL  AS   VEH_OPT5 ,
NULL  AS   VEH_OPT6 ,
NULL  AS   VEH_OPT7 ,
NULL  AS   VEH_OPT8 ,
NULL  AS   VEH_OPT9 ,
NULL  AS   VEH_OPT10 ,
NULL  AS   VEH_OPT11 ,
NULL  AS   VEH_ACC1 ,
NULL  AS   VEH_ACC2 ,
NULL  AS   VEH_ACC3 ,
NULL  AS   VEH_ACC4 ,
NULL  AS   VEH_ACC5 ,
NULL  AS   VEH_TRF1 ,
NULL  AS   VEH_TRF2 ,
NULL  AS   VEH_TRF3 ,
NULL  AS   VEH_TRF4 ,
T90.RACH_CODE_RRDI  AS   PDV_RP_RRDI ,
RCLI.NOM  PDV_RP_NOM, -- FPHQTTI.NOM  AS   PDV_RP_NOM ,
RCLI.NOM  PDV_REPRENEUR_RAISON_SOCIALE, -- FPHQTTI.NOM  AS   PDV_REPRENEUR_RAISON_SOCIALE ,
CONCAT(RCLI.ANC_NO_RUE, concat(' ', RCLI.ANC_NOM_RUE)) PDV_REPRENEUR_ADRESSE, -- CONCAT(FPHQTTI.ANC_NO_RUE, ' ', FPHQTTI.ANC_NOM_RUE)  AS   PDV_REPRENEUR_ADRESSE ,
RCLI.ANC_CODE_POSTAL  PDV_REPRENEUR_CODE_POSTAL, -- FPHQTTI.ANC_CODE_POSTAL  AS   PDV_REPRENEUR_CODE_POSTAL ,
RCLI.ANC_LOCALITE PDV_REPRENEUR_VILLE, -- FPHQTTI.ANC_LOCALITE  AS   PDV_REPRENEUR_VILLE ,
NULL  AS   PDV_FT_RRDI ,
NULL  AS   PDV_FT_NOM ,
NULL  AS   CD_VENDEUR ,
NULL  AS   PDV_VD_NOM ,
NULL  AS   PDV_FOURNISSEUR_RAISON_SOCIALE ,
NULL  AS   PDV_FOURNISSEUR_ADRESSE ,
NULL  AS   PDV_FOURNISSEUR_CODE_POSTAL ,
NULL  AS   PDV_FOURNISSEUR_VILLE 


From Fph.Fphqt90 T90,
Fph.Fphqt91,
-- Fph.Fphqt92,
Fph.Fphqtti CLIE,
Fph.Fphqtti PCLI,
Fph.Fphqtti CHAU,
Fph.Fphqtti RCLI,
Fph.Fphqtvb,
Fph.Fphqtde,
Fph.Fphqtfv,
fph.FPHQTCL
Where T90.Ie_Affaire = Fph.Fphqt91.Ie_Affaire
And CLIE.Ie_Affaire(+) = T90.Ie_Affaire AND CLIE.ROLE_TIERS(+) = 'CLIE' AND CLIE.DATE_TRAITEMENT(+) = T90.DATE_TRAITEMENT
And PCLI.Ie_Affaire(+) = T90.Ie_Affaire AND PCLI.ROLE_TIERS(+) = 'PCLI' AND PCLI.DATE_TRAITEMENT(+) = T90.DATE_TRAITEMENT
And CHAU.Ie_Affaire(+) = T90.Ie_Affaire AND CHAU.ROLE_TIERS(+) = 'CHAU' AND CHAU.DATE_TRAITEMENT(+) = T90.DATE_TRAITEMENT
And RCLI.Ie_Affaire(+) = T90.Ie_Affaire AND RCLI.ROLE_TIERS(+) = 'RCLI' AND RCLI.DATE_TRAITEMENT(+) = T90.DATE_TRAITEMENT
And Fph.Fphqtvb.Vb_Vin(+) = T90.Vin
AND FPH.FPHQTVB.VB_FLAG_PERTINENT(+) = 'Y'
And T90.Ie_Affaire = FPH.fphqtde.De_Num_Contrat(+)
And Fph.Fphqtde.De_Fg_Version(+) = 1
And Fph.Fphqtfv.Fv_Cd_Fam_Vehicule(+) = Fph.Fphqtde.Fv_Cd_Fam_Vehicule
And Fph.Fphqtfv.Fv_Cdpays(+) = Fph.Fphqtde.Py_Cd_Pays
And T90.Py_Cd_Pays = 'ES' -- AJOUT DU PAYS
AND FPH.FPHQTDE.CL_NUM_BCU = FPH.FPHQTCL.CL_NUM_BCU(+)
AND FPH.FPHQTDE.PY_CD_PAYS = FPH.FPHQTCL.PY_CD_PAYS(+) ;


 
   BEGIN

				FILE_ID := FPH.FPHQAUT.F_OPEN(NOMLOG);
                RES := FPH.FPHQAUT.F_WRITE(FILE_ID, '-------------     BEGIN     ------------------');
				RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'ALIM_DONNEES_FPHQT2_ES ## Alimentation de la table FPHQT_ES_CTT#'); 
				RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'ALIM_DONNEES_FPHQT2_ES ## Flux plusieurs tables   ##'); 
		
		
				FOR S_FDHT_ALIM  IN C_FDHT_ALIM  LOOP  
				

					BEGIN

						IF V_ERR=1 THEN EXIT;   /* exit permet de sortir de la boucle (UNIQUEMENT) */
						END IF;

						IF MOD(V_UPD + V_INS, 100)=0 THEN COMMIT;
						END IF;

           if  (S_FDHT_ALIM.CTR_KM_PIVOT = 0) then val_ecart_km := null ; -- RES := FPH.FPHQAUT.F_WRITE(FILE_ID, ' CTR_KM_PIVOT=0, val_ecart_km = null' );
           elsif (S_FDHT_ALIM.CTR_KM_PIVOT is null)  then val_ecart_km := null ; -- RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'CTR_KM_PIVOT is null, val_ecart_km = null' );
           elsif  (S_FDHT_ALIM.GIFP_PROJ_KM_FCT = 0) then val_ecart_km := null ; -- RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'GIFP_PROJ_KM_FCT = 0, val_ecart_km = null' );
           elsif (S_FDHT_ALIM.GIFP_PROJ_KM_FCT is null)  then val_ecart_km := null ; -- RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'GIFP_PROJ_KM_FCT is null, val_ecart_km = null' );
             elsif        ((NVL(S_FDHT_ALIM.GIFP_PROJ_KM_FCT,'0') - NVL(S_FDHT_ALIM.CTR_KM_PIVOT,'0')) =0 ) then val_ecart_km := null; --  RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'diff=0, val_ecart_km = null' );                                                                                                             
          else   val_ecart_km := S_FDHT_ALIM.GIFP_PROJ_KM_FCT - S_FDHT_ALIM.CTR_KM_PIVOT ; -- RES := FPH.FPHQAUT.F_WRITE(FILE_ID, ' val_ecart_km = ' ||val_ecart_km);
          end if; 
          
    

						INSERT INTO FPH.FPHQT_ES_CTT  /* T */
								(                 
Date_Traitement,         
CD_PAYS ,
CD_SOURCE ,
RESEAU ,
CTR_NUM_1 ,
CTR_NUM_2 ,
BUY_BACK_TYPE ,
CL_SIREN ,
CL_NOM ,
TVA_CD ,
CL_TYP_LIB ,
CL_APE_CD ,
CL_APE_LIB ,
CL_ADR_FACT ,
CL_ADR_CP ,
CL_ADR_VILLE ,
CTR_RETAIL ,
CIVILITE_SIGNATAIRE ,
NOM_SIGNATAIRE ,
PRENOM_SIGNATAIRE ,
TEL_CONTACT ,
EMAIL_SIGNATAIRE ,
DUREE_INI ,
KM_PIVOT_INI ,
ER_PIVOT_INI ,
CTR_DT_FIN ,
CTR_DMIN_B2 ,
CTR_DMIN_B1 ,
CTR_DTOT ,
CTR_DMAX_B1 ,
CTR_DMAX_B2 ,
CTR_KMIN_B2 ,
CTR_KMIN_B1 ,
CTR_KM_PIVOT ,
CTR_KMAX_B1 ,
CTR_KMAX_B2 ,
CTR_ERMIN_B2 ,
CTR_ERMIN_B1 ,
CTR_ER_HT ,
CTR_ERMAX_B1 ,
CTR_ERMAX_B2 ,
GIFP_DER_KM ,
GIFP_DT_DER_KM ,
GIFP_ORIG_DER_KM ,
GIFP_PROJ_KM_FCT ,
v_ecart_km , ------------
CTR_TYP_SOUP ,
REDEV_KM_EXCED ,
LOY_MTHT_FIN ,
LOY_MT_HT ,
LOY_MT_TTC ,
LOY_FLG_GPF ,
LOY_FLG_MAIN ,
LOY_PCT_CEM ,
LOY_FLG_TR ,
LOY_FLG_ASS ,
LOY_FLG_IP ,
LOY_FLG_AFD ,
LOY_FLG_CARBU ,
FLAG_PNEUS_ETE ,
FLAG_PNEUS_HIVER ,
FLAG_VEHICULE_DE_REMPLACEMENT ,
FLAG_CEM_FLEX ,
FLAG_PNEU_MIXTE ,
FLAG_JOCKEY ,
FLAG_PASS_RESTIT ,
VEH_FAM ,
VEH_LIB_LS ,
VEH_LCDV ,
VEH_LCDV_LIB ,
CARROSSERIE ,
VEH_COUL ,
VEH_GENRE ,
VEH_NRJ ,
VEH_CO2 ,
VEH_PUIS_FISC ,
VEH_TYP_MINE ,
VEH_NO_SERIE ,
VEH_BLVD ,
VEH_NO_IMMAT ,
CTR_DT_LIV ,
NOM_CHAUFFEUR ,
GENRE_CD_TRANSCO ,
VEH_MTHT_CAT ,
VEH_MTHT_OPT ,
VEH_PCT_REM ,
VEH_MTHT_ACC ,
VEH_MTHT_TRANS ,
VEH_GARN ,
VEH_OPT1 ,
VEH_OPT2 ,
VEH_OPT3 ,
VEH_OPT4 ,
VEH_OPT5 ,
VEH_OPT6 ,
VEH_OPT7 ,
VEH_OPT8 ,
VEH_OPT9 ,
VEH_OPT10 ,
VEH_OPT11 ,
VEH_ACC1 ,
VEH_ACC2 ,
VEH_ACC3 ,
VEH_ACC4 ,
VEH_ACC5 ,
VEH_TRF1 ,
VEH_TRF2 ,
VEH_TRF3 ,
VEH_TRF4 ,
PDV_RP_RRDI ,
PDV_RP_NOM ,
PDV_REPRENEUR_RAISON_SOCIALE ,
PDV_REPRENEUR_ADRESSE ,
PDV_REPRENEUR_CODE_POSTAL ,
PDV_REPRENEUR_VILLE ,
PDV_FT_RRDI ,
PDV_FT_NOM ,
CD_VENDEUR ,
PDV_VD_NOM ,
PDV_FOURNISSEUR_RAISON_SOCIALE ,
PDV_FOURNISSEUR_ADRESSE ,
PDV_FOURNISSEUR_CODE_POSTAL ,
PDV_FOURNISSEUR_VILLE 

								)
						VALUES
								(                /* CURSEUR */
                
S_FDHT_ALIM.Date_Traitement ,
S_FDHT_ALIM.CD_PAYS ,
S_FDHT_ALIM.CD_SOURCE ,
S_FDHT_ALIM.RESEAU ,
S_FDHT_ALIM.CTR_NUM_1 ,
S_FDHT_ALIM.CTR_NUM_2 ,
S_FDHT_ALIM.BUY_BACK_TYPE ,
S_FDHT_ALIM.CL_SIREN ,
S_FDHT_ALIM.CL_NOM ,
S_FDHT_ALIM.TVA_CD ,
S_FDHT_ALIM.CL_TYP_LIB ,
S_FDHT_ALIM.CL_APE_CD ,
S_FDHT_ALIM.CL_APE_LIB ,
S_FDHT_ALIM.CL_ADR_FACT ,
S_FDHT_ALIM.CL_ADR_CP ,
S_FDHT_ALIM.CL_ADR_VILLE ,
S_FDHT_ALIM.CTR_RETAIL ,
S_FDHT_ALIM.CIVILITE_SIGNATAIRE ,
S_FDHT_ALIM.NOM_SIGNATAIRE ,
S_FDHT_ALIM.PRENOM_SIGNATAIRE ,
S_FDHT_ALIM.TEL_CONTACT ,
S_FDHT_ALIM.EMAIL_SIGNATAIRE ,
S_FDHT_ALIM.DUREE_INI ,
S_FDHT_ALIM.KM_PIVOT_INI ,
S_FDHT_ALIM.ER_PIVOT_INI ,
S_FDHT_ALIM.CTR_DT_FIN ,
S_FDHT_ALIM.CTR_DMIN_B2 ,
S_FDHT_ALIM.CTR_DMIN_B1 ,
S_FDHT_ALIM.CTR_DTOT ,
S_FDHT_ALIM.CTR_DMAX_B1 ,
S_FDHT_ALIM.CTR_DMAX_B2 ,
S_FDHT_ALIM.CTR_KMIN_B2 ,
S_FDHT_ALIM.CTR_KMIN_B1 ,
S_FDHT_ALIM.CTR_KM_PIVOT ,
S_FDHT_ALIM.CTR_KMAX_B1 ,
S_FDHT_ALIM.CTR_KMAX_B2 ,
S_FDHT_ALIM.CTR_ERMIN_B2 ,
S_FDHT_ALIM.CTR_ERMIN_B1 ,
S_FDHT_ALIM.CTR_ER_HT ,
S_FDHT_ALIM.CTR_ERMAX_B1 ,
S_FDHT_ALIM.CTR_ERMAX_B2 ,
S_FDHT_ALIM.GIFP_DER_KM ,
S_FDHT_ALIM.GIFP_DT_DER_KM ,
S_FDHT_ALIM.GIFP_ORIG_DER_KM ,
S_FDHT_ALIM.GIFP_PROJ_KM_FCT ,
val_ecart_km , --------------------
S_FDHT_ALIM.CTR_TYP_SOUP ,
S_FDHT_ALIM.REDEV_KM_EXCED ,
S_FDHT_ALIM.LOY_MTHT_FIN ,
S_FDHT_ALIM.LOY_MT_HT ,
S_FDHT_ALIM.LOY_MT_TTC ,
S_FDHT_ALIM.LOY_FLG_GPF ,
S_FDHT_ALIM.LOY_FLG_MAIN ,
S_FDHT_ALIM.LOY_PCT_CEM ,
S_FDHT_ALIM.LOY_FLG_TR ,
S_FDHT_ALIM.LOY_FLG_ASS ,
S_FDHT_ALIM.LOY_FLG_IP ,
S_FDHT_ALIM.LOY_FLG_AFD ,
S_FDHT_ALIM.LOY_FLG_CARBU ,
S_FDHT_ALIM.FLAG_PNEUS_ETE ,
S_FDHT_ALIM.FLAG_PNEUS_HIVER ,
S_FDHT_ALIM.FLAG_VEHICULE_DE_REMPLACEMENT ,
S_FDHT_ALIM.FLAG_CEM_FLEX ,
S_FDHT_ALIM.FLAG_PNEU_MIXTE ,
S_FDHT_ALIM.FLAG_JOCKEY ,
S_FDHT_ALIM.FLAG_PASS_RESTIT ,
S_FDHT_ALIM.VEH_FAM ,
S_FDHT_ALIM.VEH_LIB_LS ,
S_FDHT_ALIM.VEH_LCDV ,
S_FDHT_ALIM.VEH_LCDV_LIB ,
S_FDHT_ALIM.CARROSSERIE ,
S_FDHT_ALIM.VEH_COUL ,
S_FDHT_ALIM.VEH_GENRE ,
S_FDHT_ALIM.VEH_NRJ ,
S_FDHT_ALIM.VEH_CO2 ,
S_FDHT_ALIM.VEH_PUIS_FISC ,
S_FDHT_ALIM.VEH_TYP_MINE ,
S_FDHT_ALIM.VEH_NO_SERIE ,
S_FDHT_ALIM.VEH_BLVD ,
S_FDHT_ALIM.VEH_NO_IMMAT ,
S_FDHT_ALIM.CTR_DT_LIV ,
S_FDHT_ALIM.NOM_CHAUFFEUR ,
S_FDHT_ALIM.GENRE_CD_TRANSCO ,
S_FDHT_ALIM.VEH_MTHT_CAT ,
S_FDHT_ALIM.VEH_MTHT_OPT ,
S_FDHT_ALIM.VEH_PCT_REM ,
S_FDHT_ALIM.VEH_MTHT_ACC ,
S_FDHT_ALIM.VEH_MTHT_TRANS ,
S_FDHT_ALIM.VEH_GARN ,
S_FDHT_ALIM.VEH_OPT1 ,
S_FDHT_ALIM.VEH_OPT2 ,
S_FDHT_ALIM.VEH_OPT3 ,
S_FDHT_ALIM.VEH_OPT4 ,
S_FDHT_ALIM.VEH_OPT5 ,
S_FDHT_ALIM.VEH_OPT6 ,
S_FDHT_ALIM.VEH_OPT7 ,
S_FDHT_ALIM.VEH_OPT8 ,
S_FDHT_ALIM.VEH_OPT9 ,
S_FDHT_ALIM.VEH_OPT10 ,
S_FDHT_ALIM.VEH_OPT11 ,
S_FDHT_ALIM.VEH_ACC1 ,
S_FDHT_ALIM.VEH_ACC2 ,
S_FDHT_ALIM.VEH_ACC3 ,
S_FDHT_ALIM.VEH_ACC4 ,
S_FDHT_ALIM.VEH_ACC5 ,
S_FDHT_ALIM.VEH_TRF1 ,
S_FDHT_ALIM.VEH_TRF2 ,
S_FDHT_ALIM.VEH_TRF3 ,
S_FDHT_ALIM.VEH_TRF4 ,
S_FDHT_ALIM.PDV_RP_RRDI ,
S_FDHT_ALIM.PDV_RP_NOM ,
S_FDHT_ALIM.PDV_REPRENEUR_RAISON_SOCIALE ,
S_FDHT_ALIM.PDV_REPRENEUR_ADRESSE ,
S_FDHT_ALIM.PDV_REPRENEUR_CODE_POSTAL ,
S_FDHT_ALIM.PDV_REPRENEUR_VILLE ,
S_FDHT_ALIM.PDV_FT_RRDI ,
S_FDHT_ALIM.PDV_FT_NOM ,
S_FDHT_ALIM.CD_VENDEUR ,
S_FDHT_ALIM.PDV_VD_NOM ,
S_FDHT_ALIM.PDV_FOURNISSEUR_RAISON_SOCIALE ,
S_FDHT_ALIM.PDV_FOURNISSEUR_ADRESSE ,
S_FDHT_ALIM.PDV_FOURNISSEUR_CODE_POSTAL ,
S_FDHT_ALIM.PDV_FOURNISSEUR_VILLE 								
								);

                    V_INS := V_INS + 1;

					
					EXCEPTION

						WHEN DUP_VAL_ON_INDEX THEN
						UPDATE  FPH.FPHQT_ES_CTT     /* T */
						SET     /* CURSEUR */
Date_Traitement  =  S_FDHT_ALIM.Date_Traitement ,
--CD_PAYS  =  S_FDHT_ALIM.CD_PAYS ,
CD_SOURCE  =  S_FDHT_ALIM.CD_SOURCE ,
RESEAU  =  S_FDHT_ALIM.RESEAU ,
--CTR_NUM_1  =  S_FDHT_ALIM.CTR_NUM_1 ,
CTR_NUM_2  =  S_FDHT_ALIM.CTR_NUM_2 ,
BUY_BACK_TYPE  =  S_FDHT_ALIM.BUY_BACK_TYPE ,
CL_SIREN  =  S_FDHT_ALIM.CL_SIREN ,
CL_NOM  =  S_FDHT_ALIM.CL_NOM ,
TVA_CD  =  S_FDHT_ALIM.TVA_CD ,
CL_TYP_LIB  =  S_FDHT_ALIM.CL_TYP_LIB ,
CL_APE_CD  =  S_FDHT_ALIM.CL_APE_CD ,
CL_APE_LIB  =  S_FDHT_ALIM.CL_APE_LIB ,
CL_ADR_FACT  =  S_FDHT_ALIM.CL_ADR_FACT ,
CL_ADR_CP  =  S_FDHT_ALIM.CL_ADR_CP ,
CL_ADR_VILLE  =  S_FDHT_ALIM.CL_ADR_VILLE ,
CTR_RETAIL  =  S_FDHT_ALIM.CTR_RETAIL ,
CIVILITE_SIGNATAIRE  =  S_FDHT_ALIM.CIVILITE_SIGNATAIRE ,
NOM_SIGNATAIRE  =  S_FDHT_ALIM.NOM_SIGNATAIRE ,
PRENOM_SIGNATAIRE  =  S_FDHT_ALIM.PRENOM_SIGNATAIRE ,
TEL_CONTACT  =  S_FDHT_ALIM.TEL_CONTACT ,
EMAIL_SIGNATAIRE  =  S_FDHT_ALIM.EMAIL_SIGNATAIRE ,
DUREE_INI  =  S_FDHT_ALIM.DUREE_INI ,
KM_PIVOT_INI  =  S_FDHT_ALIM.KM_PIVOT_INI ,
ER_PIVOT_INI  =  S_FDHT_ALIM.ER_PIVOT_INI ,
CTR_DT_FIN  =  S_FDHT_ALIM.CTR_DT_FIN ,
CTR_DMIN_B2  =  S_FDHT_ALIM.CTR_DMIN_B2 ,
CTR_DMIN_B1  =  S_FDHT_ALIM.CTR_DMIN_B1 ,
CTR_DTOT  =  S_FDHT_ALIM.CTR_DTOT ,
CTR_DMAX_B1  =  S_FDHT_ALIM.CTR_DMAX_B1 ,
CTR_DMAX_B2  =  S_FDHT_ALIM.CTR_DMAX_B2 ,
CTR_KMIN_B2  =  S_FDHT_ALIM.CTR_KMIN_B2 ,
CTR_KMIN_B1  =  S_FDHT_ALIM.CTR_KMIN_B1 ,
CTR_KM_PIVOT  =  S_FDHT_ALIM.CTR_KM_PIVOT ,
CTR_KMAX_B1  =  S_FDHT_ALIM.CTR_KMAX_B1 ,
CTR_KMAX_B2  =  S_FDHT_ALIM.CTR_KMAX_B2 ,
CTR_ERMIN_B2  =  S_FDHT_ALIM.CTR_ERMIN_B2 ,
CTR_ERMIN_B1  =  S_FDHT_ALIM.CTR_ERMIN_B1 ,
CTR_ER_HT  =  S_FDHT_ALIM.CTR_ER_HT ,
CTR_ERMAX_B1  =  S_FDHT_ALIM.CTR_ERMAX_B1 ,
CTR_ERMAX_B2  =  S_FDHT_ALIM.CTR_ERMAX_B2 ,
GIFP_DER_KM  =  S_FDHT_ALIM.GIFP_DER_KM ,
GIFP_DT_DER_KM  =  S_FDHT_ALIM.GIFP_DT_DER_KM ,
GIFP_ORIG_DER_KM  =  S_FDHT_ALIM.GIFP_ORIG_DER_KM ,
GIFP_PROJ_KM_FCT  =  S_FDHT_ALIM.GIFP_PROJ_KM_FCT ,
v_ecart_km  =  val_ecart_km ,
CTR_TYP_SOUP  =  S_FDHT_ALIM.CTR_TYP_SOUP ,
REDEV_KM_EXCED  =  S_FDHT_ALIM.REDEV_KM_EXCED ,
LOY_MTHT_FIN  =  S_FDHT_ALIM.LOY_MTHT_FIN ,
LOY_MT_HT  =  S_FDHT_ALIM.LOY_MT_HT ,
LOY_MT_TTC  =  S_FDHT_ALIM.LOY_MT_TTC ,
LOY_FLG_GPF  =  S_FDHT_ALIM.LOY_FLG_GPF ,
LOY_FLG_MAIN  =  S_FDHT_ALIM.LOY_FLG_MAIN ,
LOY_PCT_CEM  =  S_FDHT_ALIM.LOY_PCT_CEM ,
LOY_FLG_TR  =  S_FDHT_ALIM.LOY_FLG_TR ,
LOY_FLG_ASS  =  S_FDHT_ALIM.LOY_FLG_ASS ,
LOY_FLG_IP  =  S_FDHT_ALIM.LOY_FLG_IP ,
LOY_FLG_AFD  =  S_FDHT_ALIM.LOY_FLG_AFD ,
LOY_FLG_CARBU  =  S_FDHT_ALIM.LOY_FLG_CARBU ,
FLAG_PNEUS_ETE  =  S_FDHT_ALIM.FLAG_PNEUS_ETE ,
FLAG_PNEUS_HIVER  =  S_FDHT_ALIM.FLAG_PNEUS_HIVER ,
FLAG_VEHICULE_DE_REMPLACEMENT  =  S_FDHT_ALIM.FLAG_VEHICULE_DE_REMPLACEMENT ,
FLAG_CEM_FLEX  =  S_FDHT_ALIM.FLAG_CEM_FLEX ,
FLAG_PNEU_MIXTE  =  S_FDHT_ALIM.FLAG_PNEU_MIXTE ,
FLAG_JOCKEY  =  S_FDHT_ALIM.FLAG_JOCKEY ,
FLAG_PASS_RESTIT  =  S_FDHT_ALIM.FLAG_PASS_RESTIT ,
VEH_FAM  =  S_FDHT_ALIM.VEH_FAM ,  ---------EXCEPTION, SUPPRIMER APRES QUAND ON AURA LES DONNNES DANS ## select FV_CD_FAM_VEHICULE from FPHQTFV   ##
VEH_LIB_LS  =  S_FDHT_ALIM.VEH_LIB_LS ,
VEH_LCDV  =  S_FDHT_ALIM.VEH_LCDV ,
VEH_LCDV_LIB  =  S_FDHT_ALIM.VEH_LCDV_LIB ,
CARROSSERIE  =  S_FDHT_ALIM.CARROSSERIE ,
VEH_COUL  =  S_FDHT_ALIM.VEH_COUL ,
VEH_GENRE  =  S_FDHT_ALIM.VEH_GENRE ,
VEH_NRJ  =  S_FDHT_ALIM.VEH_NRJ ,
VEH_CO2  =  S_FDHT_ALIM.VEH_CO2 ,
VEH_PUIS_FISC  =  S_FDHT_ALIM.VEH_PUIS_FISC ,
VEH_TYP_MINE  =  S_FDHT_ALIM.VEH_TYP_MINE ,
VEH_NO_SERIE  =  S_FDHT_ALIM.VEH_NO_SERIE ,
VEH_BLVD  =  S_FDHT_ALIM.VEH_BLVD ,
VEH_NO_IMMAT  =  S_FDHT_ALIM.VEH_NO_IMMAT ,
CTR_DT_LIV  =  S_FDHT_ALIM.CTR_DT_LIV ,
NOM_CHAUFFEUR  =  S_FDHT_ALIM.NOM_CHAUFFEUR ,
GENRE_CD_TRANSCO  =  S_FDHT_ALIM.GENRE_CD_TRANSCO ,
VEH_MTHT_CAT  =  S_FDHT_ALIM.VEH_MTHT_CAT ,
VEH_MTHT_OPT  =  S_FDHT_ALIM.VEH_MTHT_OPT ,
VEH_PCT_REM  =  S_FDHT_ALIM.VEH_PCT_REM ,
VEH_MTHT_ACC  =  S_FDHT_ALIM.VEH_MTHT_ACC ,
VEH_MTHT_TRANS  =  S_FDHT_ALIM.VEH_MTHT_TRANS ,
VEH_GARN  =  S_FDHT_ALIM.VEH_GARN ,
VEH_OPT1  =  S_FDHT_ALIM.VEH_OPT1 ,
VEH_OPT2  =  S_FDHT_ALIM.VEH_OPT2 ,
VEH_OPT3  =  S_FDHT_ALIM.VEH_OPT3 ,
VEH_OPT4  =  S_FDHT_ALIM.VEH_OPT4 ,
VEH_OPT5  =  S_FDHT_ALIM.VEH_OPT5 ,
VEH_OPT6  =  S_FDHT_ALIM.VEH_OPT6 ,
VEH_OPT7  =  S_FDHT_ALIM.VEH_OPT7 ,
VEH_OPT8  =  S_FDHT_ALIM.VEH_OPT8 ,
VEH_OPT9  =  S_FDHT_ALIM.VEH_OPT9 ,
VEH_OPT10  =  S_FDHT_ALIM.VEH_OPT10 ,
VEH_OPT11  =  S_FDHT_ALIM.VEH_OPT11 ,
VEH_ACC1  =  S_FDHT_ALIM.VEH_ACC1 ,
VEH_ACC2  =  S_FDHT_ALIM.VEH_ACC2 ,
VEH_ACC3  =  S_FDHT_ALIM.VEH_ACC3 ,
VEH_ACC4  =  S_FDHT_ALIM.VEH_ACC4 ,
VEH_ACC5  =  S_FDHT_ALIM.VEH_ACC5 ,
VEH_TRF1  =  S_FDHT_ALIM.VEH_TRF1 ,
VEH_TRF2  =  S_FDHT_ALIM.VEH_TRF2 ,
VEH_TRF3  =  S_FDHT_ALIM.VEH_TRF3 ,
VEH_TRF4  =  S_FDHT_ALIM.VEH_TRF4 ,
PDV_RP_RRDI  =  S_FDHT_ALIM.PDV_RP_RRDI ,
PDV_RP_NOM  =  S_FDHT_ALIM.PDV_RP_NOM ,
PDV_REPRENEUR_RAISON_SOCIALE  =  S_FDHT_ALIM.PDV_REPRENEUR_RAISON_SOCIALE ,
PDV_REPRENEUR_ADRESSE  =  S_FDHT_ALIM.PDV_REPRENEUR_ADRESSE ,
PDV_REPRENEUR_CODE_POSTAL  =  S_FDHT_ALIM.PDV_REPRENEUR_CODE_POSTAL ,
PDV_REPRENEUR_VILLE  =  S_FDHT_ALIM.PDV_REPRENEUR_VILLE ,
PDV_FT_RRDI  =  S_FDHT_ALIM.PDV_FT_RRDI ,
PDV_FT_NOM  =  S_FDHT_ALIM.PDV_FT_NOM ,
CD_VENDEUR  =  S_FDHT_ALIM.CD_VENDEUR ,
PDV_VD_NOM  =  S_FDHT_ALIM.PDV_VD_NOM ,
PDV_FOURNISSEUR_RAISON_SOCIALE  =  S_FDHT_ALIM.PDV_FOURNISSEUR_RAISON_SOCIALE ,
PDV_FOURNISSEUR_ADRESSE  =  S_FDHT_ALIM.PDV_FOURNISSEUR_ADRESSE ,
PDV_FOURNISSEUR_CODE_POSTAL  =  S_FDHT_ALIM.PDV_FOURNISSEUR_CODE_POSTAL ,
PDV_FOURNISSEUR_VILLE  =  S_FDHT_ALIM.PDV_FOURNISSEUR_VILLE 

                Where Ctr_Num_1 = S_Fdht_Alim.Ctr_Num_1 
                and CD_PAYS ='ES' ;
                
                                                --IE_AFFAIRE, VB_VIN, DE_FG_VERSION, FV_CD_FAM_VEHICULE, FV_CDPAYS
					
						V_UPD := V_UPD + 1;

		
						WHEN OTHERS THEN  
							COMMIT;  
							V_ERR := 1;
              
							V_ERROR := SUBSTR('SQLCODE: '||TO_CHAR(SQLCODE)||' -ERROR: '||SQLERRM,1,4000);   
							RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'ALIM_DONNEES_FPHQT2_ES #WHEN OTHERS THEN# Message Erreur pl/sql :' ||SQLERRM);
								
						RETURN V_ERR;
					END;
				END LOOP;

        COMMIT;

     res := FPH.FPHQAUT.F_WRITE(file_id, 'ALIM_LSITCVVN Nombre de creations :'||V_INS);
     res := FPH.FPHQAUT.F_WRITE(file_id, 'ALIM_LSITCVVN Nombre de mises a jour :'||V_UPD);
     --res := FPH.FPHQAUT.F_WRITE(file_id, 'ALIM_LSITCVVN Nombre de suppressions :'||v_SUP);
     res := FPH.FPHQAUT.F_WRITE(file_id, '');
     UTL_FILE.FCLOSE(file_id);
     -- 
     v_inserts := V_INS;
     v_updates := V_UPD;
				RETURN V_ERR;
			End;

		/* end; */
   

    
  END ALIM_DONNEES_FPHQT2_ES;





  FUNCTION EXPORT_FPHQT2_ES (NOMLOG      VARCHAR2,
                        P_DATE_TRAI DATE,                 
                       P_PATH    VARCHAR2,
                        P_FILENAME  VARCHAR2) RETURN NUMBER IS
  
  
        V_ERR           NUMBER := 0;	/* erreur qui voudra 0 ou 1 */
		N_SAUV          NUMBER:=0;		/* nombre de lignes sauvegardés*/
		v_ligne         VARCHAR2(4000);		/* variable qui stocke les données d'une ligne */
		file_id_cvs     utl_file.file_type;  /*F_OPEN_CSV*/
		file_name       VARCHAR2(30); 	 /* nom du fichier dans lequel on va exporter les données*/

    

		FILE_ID   UTL_FILE.FILE_TYPE;  /* open */
		RES       NUMBER := 0;			/* write */
  
   
  
        CURSOR C_FDHT_EXP IS  
        select * from FPH.FPHQT_ES_CTT;  
    

		Begin
        
        file_name := p_filename;
        File_Id := Fph.Fphqaut.F_Open(Nomlog);
        RES := FPH.FPHQAUT.F_WRITE(FILE_ID, '-------------     BEGIN     ------------------');
        Res := Fph.Fphqaut.F_Write(File_Id, 'EXPORT_FPHQT2_ES ## DEBUT DE EXPORT FPHQT_ES_CTT#'); 
        RES := FPH.FPHQAUT.F_WRITE(FILE_ID, 'EXPORT_FPHQT2_ES ## NOM DU FICHIER DAT :   ##'||P_FILENAME); 
        File_Id_Cvs:= Fph.Fphqaut.F_Open_Cvs(P_Path,File_Name);  
        V_LIGNE := 'Date_traitement|CD_PAYS|CD_SOURCE|RESEAU|CTR_NUM|CTR_NUM|BUY_BACK_TYPE|CL_SIREN|CL_NOM|TVA_CD|CL_TYP_LIB|CL_APE_CD|CL_APE_LIB|CL_ADR_FACT|CL_ADR_CP|CL_ADR_VILLE|CTR_RETAIL|CIVILITE_SIGNATAIRE|NOM_SIGNATAIRE|PRENOM_SIGNATAIRE|TEL_CONTACT|EMAIL_SIGNATAIRE|DUREE_INI|KM_PIVOT_INI|ER_PIVOT_INI|CTR_DT_FIN|CTR_DMIN_B2|CTR_DMIN_B1|CTR_DTOT|CTR_DMAX_B1|CTR_DMAX_B2|CTR_KMIN_B2|CTR_KMIN_B1|CTR_KM_PIVOT|CTR_KMAX_B1|CTR_KMAX_B2|CTR_ERMIN_B2|CTR_ERMIN_B1|CTR_ER_HT|CTR_ERMAX_B1|CTR_ERMAX_B2|GIFP_DER_KM|GIFP_DT_DER_KM|GIFP_ORIG_DER_KM|GIFP_PROJ_KM_FCT|v_ecart_km|CTR_TYP_SOUP|REDEV_KM_EXCED|LOY_MTHT_FIN|LOY_MT_HT|LOY_MT_TTC|LOY_FLG_GPF|LOY_FLG_MAIN|LOY_PCT_CEM|LOY_FLG_TR|LOY_FLG_ASS|LOY_FLG_IP|LOY_FLG_AFD|LOY_FLG_CARBU|FLAG_PNEUS_ETE|FLAG_PNEUS_HIVER|FLAG_VEHICULE_DE_REMPLACEMENT|FLAG_CEM_FLEX|FLAG_PNEU_MIXTE|FLAG_JOCKEY|FLAG_PASS_RESTIT|VEH_FAM|VEH_LIB_LS|VEH_LCDV|VEH_LCDV_LIB|CARROSSERIE|VEH_COUL|VEH_GENRE|VEH_NRJ|VEH_CO2|VEH_PUIS_FISC|VEH_TYP_MINE|VEH_NO_SERIE|VEH_BLVD|VEH_NO_IMMAT|CTR_DT_LIV|NOM_CHAUFFEUR|GENRE_CD_TRANSCO|VEH_MTHT_CAT|VEH_MTHT_OPT|VEH_PCT_REM|VEH_MTHT_ACC|VEH_MTHT_TRANS|VEH_GARN|VEH_OPT1|VEH_OPT2|VEH_OPT3|VEH_OPT4|VEH_OPT5|VEH_OPT6|VEH_OPT7|VEH_OPT8|VEH_OPT9|VEH_OPT10|VEH_OPT11|VEH_ACC1|VEH_ACC2|VEH_ACC3|VEH_ACC4|VEH_ACC5|VEH_TRF1|VEH_TRF2|VEH_TRF3|VEH_TRF4|PDV_RP_RRDI|PDV_RP_NOM|PDV_REPRENEUR_RAISON_SOCIALE|PDV_REPRENEUR_ADRESSE|PDV_REPRENEUR_CODE_POSTAL|PDV_REPRENEUR_VILLE|PDV_FT_RRDI|PDV_FT_NOM|CD_VENDEUR|PDV_VD_NOM|PDV_FOURNISSEUR_RAISON_SOCIALE|PDV_FOURNISSEUR_ADRESSE|PDV_FOURNISSEUR_CODE_POSTAL|PDV_FOURNISSEUR_VILLE'; 
        UTL_FILE.PUT_LINE(file_id_cvs, v_ligne);
        


			FOR S_FDHT_EXP IN C_FDHT_EXP LOOP 

				BEGIN
        
					IF V_ERR=1 THEN EXIT;
					END IF;
          
          
          V_LIGNE := 
          S_FDHT_EXP.Date_traitement  || '|' || 
  S_FDHT_EXP.CD_PAYS    || '|' ||
S_FDHT_EXP.CD_SOURCE    || '|' ||
S_FDHT_EXP.RESEAU    || '|' ||
S_FDHT_EXP.CTR_NUM_1    || '|' ||
S_FDHT_EXP.CTR_NUM_2    || '|' ||
S_FDHT_EXP.BUY_BACK_TYPE    || '|' ||
S_FDHT_EXP.CL_SIREN    || '|' ||
S_FDHT_EXP.CL_NOM    || '|' ||
S_FDHT_EXP.TVA_CD    || '|' ||
S_FDHT_EXP.CL_TYP_LIB    || '|' ||
S_FDHT_EXP.CL_APE_CD    || '|' ||
S_FDHT_EXP.CL_APE_LIB    || '|' ||
S_FDHT_EXP.CL_ADR_FACT    || '|' ||
S_FDHT_EXP.CL_ADR_CP    || '|' ||
S_FDHT_EXP.CL_ADR_VILLE    || '|' ||
S_FDHT_EXP.CTR_RETAIL    || '|' ||
S_FDHT_EXP.CIVILITE_SIGNATAIRE    || '|' ||
S_FDHT_EXP.NOM_SIGNATAIRE    || '|' ||
S_FDHT_EXP.PRENOM_SIGNATAIRE    || '|' ||
S_FDHT_EXP.TEL_CONTACT    || '|' ||
S_FDHT_EXP.EMAIL_SIGNATAIRE    || '|' ||
S_FDHT_EXP.DUREE_INI    || '|' ||
S_FDHT_EXP.KM_PIVOT_INI    || '|' ||
S_FDHT_EXP.ER_PIVOT_INI    || '|' ||
S_FDHT_EXP.CTR_DT_FIN    || '|' ||
S_FDHT_EXP.CTR_DMIN_B2    || '|' ||
S_FDHT_EXP.CTR_DMIN_B1    || '|' ||
S_FDHT_EXP.CTR_DTOT    || '|' ||
S_FDHT_EXP.CTR_DMAX_B1    || '|' ||
S_FDHT_EXP.CTR_DMAX_B2    || '|' ||
S_FDHT_EXP.CTR_KMIN_B2    || '|' ||
S_FDHT_EXP.CTR_KMIN_B1    || '|' ||
S_FDHT_EXP.CTR_KM_PIVOT    || '|' ||
S_FDHT_EXP.CTR_KMAX_B1    || '|' ||
S_FDHT_EXP.CTR_KMAX_B2    || '|' ||
S_FDHT_EXP.CTR_ERMIN_B2    || '|' ||
S_FDHT_EXP.CTR_ERMIN_B1    || '|' ||
S_FDHT_EXP.CTR_ER_HT    || '|' ||
S_FDHT_EXP.CTR_ERMAX_B1    || '|' ||
S_FDHT_EXP.CTR_ERMAX_B2    || '|' ||
S_FDHT_EXP.GIFP_DER_KM    || '|' ||
S_FDHT_EXP.GIFP_DT_DER_KM    || '|' ||
S_FDHT_EXP.GIFP_ORIG_DER_KM    || '|' ||
S_FDHT_EXP.GIFP_PROJ_KM_FCT    || '|' ||
S_FDHT_EXP.v_ecart_km   || '|' ||  --val_ecart_km    || '|' ||
S_FDHT_EXP.CTR_TYP_SOUP    || '|' ||
S_FDHT_EXP.REDEV_KM_EXCED    || '|' ||
S_FDHT_EXP.LOY_MTHT_FIN    || '|' ||
S_FDHT_EXP.LOY_MT_HT    || '|' ||
S_FDHT_EXP.LOY_MT_TTC    || '|' ||
S_FDHT_EXP.LOY_FLG_GPF    || '|' ||
S_FDHT_EXP.LOY_FLG_MAIN    || '|' ||
S_FDHT_EXP.LOY_PCT_CEM    || '|' ||
S_FDHT_EXP.LOY_FLG_TR    || '|' ||
S_FDHT_EXP.LOY_FLG_ASS    || '|' ||
S_FDHT_EXP.LOY_FLG_IP    || '|' ||
S_FDHT_EXP.LOY_FLG_AFD    || '|' ||
S_FDHT_EXP.LOY_FLG_CARBU    || '|' ||
S_FDHT_EXP.FLAG_PNEUS_ETE    || '|' ||
S_FDHT_EXP.FLAG_PNEUS_HIVER    || '|' ||
S_FDHT_EXP.FLAG_VEHICULE_DE_REMPLACEMENT    || '|' ||
S_FDHT_EXP.FLAG_CEM_FLEX    || '|' ||
S_FDHT_EXP.FLAG_PNEU_MIXTE    || '|' ||
S_FDHT_EXP.FLAG_JOCKEY    || '|' ||
S_FDHT_EXP.FLAG_PASS_RESTIT    || '|' ||
S_FDHT_EXP.VEH_FAM    || '|' ||
S_FDHT_EXP.VEH_LIB_LS    || '|' ||
S_FDHT_EXP.VEH_LCDV    || '|' ||
S_FDHT_EXP.VEH_LCDV_LIB    || '|' ||
S_FDHT_EXP.CARROSSERIE    || '|' ||
S_FDHT_EXP.VEH_COUL    || '|' ||
S_FDHT_EXP.VEH_GENRE    || '|' ||
S_FDHT_EXP.VEH_NRJ    || '|' ||
S_FDHT_EXP.VEH_CO2    || '|' ||
S_FDHT_EXP.VEH_PUIS_FISC    || '|' ||
S_FDHT_EXP.VEH_TYP_MINE    || '|' ||
S_FDHT_EXP.VEH_NO_SERIE    || '|' ||
S_FDHT_EXP.VEH_BLVD    || '|' ||
S_FDHT_EXP.VEH_NO_IMMAT    || '|' ||
S_FDHT_EXP.CTR_DT_LIV    || '|' ||
S_FDHT_EXP.NOM_CHAUFFEUR    || '|' ||
S_FDHT_EXP.GENRE_CD_TRANSCO    || '|' ||
S_FDHT_EXP.VEH_MTHT_CAT    || '|' ||
S_FDHT_EXP.VEH_MTHT_OPT    || '|' ||
S_FDHT_EXP.VEH_PCT_REM    || '|' ||
S_FDHT_EXP.VEH_MTHT_ACC    || '|' ||
S_FDHT_EXP.VEH_MTHT_TRANS    || '|' ||
S_FDHT_EXP.VEH_GARN    || '|' ||
S_FDHT_EXP.VEH_OPT1    || '|' ||
S_FDHT_EXP.VEH_OPT2    || '|' ||
S_FDHT_EXP.VEH_OPT3    || '|' ||
S_FDHT_EXP.VEH_OPT4    || '|' ||
S_FDHT_EXP.VEH_OPT5    || '|' ||
S_FDHT_EXP.VEH_OPT6    || '|' ||
S_FDHT_EXP.VEH_OPT7    || '|' ||
S_FDHT_EXP.VEH_OPT8    || '|' ||
S_FDHT_EXP.VEH_OPT9    || '|' ||
S_FDHT_EXP.VEH_OPT10    || '|' ||
S_FDHT_EXP.VEH_OPT11    || '|' ||
S_FDHT_EXP.VEH_ACC1    || '|' ||
S_FDHT_EXP.VEH_ACC2    || '|' ||
S_FDHT_EXP.VEH_ACC3    || '|' ||
S_FDHT_EXP.VEH_ACC4    || '|' ||
S_FDHT_EXP.VEH_ACC5    || '|' ||
S_FDHT_EXP.VEH_TRF1    || '|' ||
S_FDHT_EXP.VEH_TRF2    || '|' ||
S_FDHT_EXP.VEH_TRF3    || '|' ||
S_FDHT_EXP.VEH_TRF4    || '|' ||
S_FDHT_EXP.PDV_RP_RRDI    || '|' ||
S_FDHT_EXP.PDV_RP_NOM    || '|' ||
S_FDHT_EXP.PDV_REPRENEUR_RAISON_SOCIALE    || '|' ||
S_FDHT_EXP.PDV_REPRENEUR_ADRESSE    || '|' ||
S_FDHT_EXP.PDV_REPRENEUR_CODE_POSTAL    || '|' ||
S_FDHT_EXP.PDV_REPRENEUR_VILLE    || '|' ||
S_FDHT_EXP.PDV_FT_RRDI    || '|' ||
S_FDHT_EXP.PDV_FT_NOM    || '|' ||
S_FDHT_EXP.CD_VENDEUR    || '|' ||
S_FDHT_EXP.PDV_VD_NOM    || '|' ||
S_Fdht_Exp.Pdv_Fournisseur_Raison_Sociale    || '|' ||
S_FDHT_EXP.PDV_FOURNISSEUR_ADRESSE    || '|' ||
S_Fdht_Exp.Pdv_Fournisseur_Code_Postal    || '|' ||
S_FDHT_EXP.PDV_FOURNISSEUR_VILLE  || '|';   

              
    res := FPH.FPHQAUT.F_WRITE_CVS(file_id_cvs, v_ligne);  

    N_SAUV := N_SAUV + 1;
				EXCEPTION
					WHEN OTHERS THEN
						COMMIT;
						V_ERR  := 1;
						res     := FPH.FPHQAUT.F_WRITE(file_id, 'EXPORT_FPHQT2_ES ## Message Erreur pl/sql : ' || SQLERRM );
                        res := FPH.FPHQAUT.F_WRITE(file_id, 'Erreur 0 ## Nombre de lignes ecrites :' || N_SAUV);
                        res := FPH.FPHQAUT.F_WRITE(file_id, 'Erreur 0 ## v_ligne :' || V_LIGNE);
					RETURN V_ERR;

				END;
			END LOOP;

    UTL_FILE.FCLOSE(file_id_cvs);
    res := FPH.FPHQAUT.F_WRITE(file_id, 'EXPORT_FPHQT2_ES ## Nombre de lignes ecrites :' || SQLERRM);
    res := FPH.FPHQAUT.F_WRITE(file_id, '## Nombre de lignes ecrites :' ||N_SAUV);
    UTL_FILE.FCLOSE(file_id);

			RETURN V_ERR;

		
    EXCEPTION 
			WHEN OTHERS THEN
				COMMIT;
				V_ERR  := 1;
				res     := FPH.FPHQAUT.F_WRITE(file_id,'EXPORT_FPHQT2_ES ## Message Erreur pl/sql : ' || SQLERRM);
                res := FPH.FPHQAUT.F_WRITE(file_id, 'Erreur 1 ## Nombre de lignes ecrites :' || N_SAUV);

			RETURN V_ERR; 


    
  END EXPORT_FPHQT2_ES;







  FUNCTION MAIN_FDSQT2_ES (NOMLOG      VARCHAR2,
                              P_DATE_TRAI DATE,
                              P_PATH VARCHAR2,
                              P_FILENAME VARCHAR2) RETURN NUMBER AS
                              
		V_RET NUMBER := 0;                     /* erreur = 0 ou 1 */

		V_INSERTS   NUMBER := 0;			/* DECLARATION DU PARAMETRE DE LA FONCTION D'ALIMENTAITON*/
		V_UPDATES   NUMBER := 0;			/* DECLARATION DU PARAMETRE DE LA FONCTION D'ALIMENTAITON*/
		V_ERROR   VARCHAR2(255);  			/* DECLARATION DU PARAMETRE DE LA FONCTION D'ALIMENTAITON*/

		V_ERR   NUMBER := 0;      /* erreur 0 ou 1 qui est envoyé de la fonction d'alimentation ou export*/
	
        BEGIN	
					
			V_ERR     := ALIM_DONNEES_FPHQT2_ES( NOMLOG , P_DATE_TRAI , V_INSERTS , V_UPDATES , V_ERROR );  
			IF V_ERR = 1 THEN
				V_RET := 1;
				RETURN V_RET;
			END IF;

			V_ERR     :=     EXPORT_FPHQT2_ES(NOMLOG, P_DATE_TRAI, P_PATH, P_FILENAME);  
			IF V_ERR = 1 THEN 
				V_RET := 1;
				RETURN V_RET;
			END IF;
			
			
			RETURN V_RET;

        
    
  END MAIN_FDSQT2_ES;
  
 

END FPHQACT2;
