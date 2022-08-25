                        command="\
                                curl -O -L https://raw.githubusercontent.com/cloud-native-toolkit/multi-tenancy-gitops-services/master/instances/cp4d-pattern-healthcare/2-datasources/patients.csv; \
                                curl -O -L https://raw.githubusercontent.com/cloud-native-toolkit/multi-tenancy-gitops-services/master/instances/cp4d-pattern-healthcare/2-datasources/encounters.csv; \
                                curl -O -L https://raw.githubusercontent.com/cloud-native-toolkit/multi-tenancy-gitops-services/master/instances/cp4d-pattern-healthcare/2-datasources/conditions.csv; \
                                db2 connect to bludb; \
                                db2 \"CREATE TABLE PATIENTS(PATIENT_ID CHAR(36) NOT NULL ,BIRTHDATE DATE , DEATHDATE DATE , SSN CHAR(36), DRIVERS_LICENSE CHAR(36), PASSPORT CHAR(36),PREFIX CHAR(6),FIRST_NAME CHAR(36),LAST_NAME CHAR(36),SUFFIX CHAR(36),MAIDEN_NAME CHAR(36),MARITAL CHAR(36),RACE CHAR(36),ETHNICITY CHAR(36),GENDER CHAR(36),BIRTHPLACE CHAR(100),ADDRESS CHAR(36),CITY CHAR(36),STATE CHAR(36),COUNTY CHAR(36),ZIP CHAR(36),LAT DOUBLE,LON DOUBLE,HEALTHCARE_EXPENSES FLOAT,HEALTHCARE_COVERAGE FLOAT, PRIMARY KEY (PATIENT_ID))\";\
                                db2 \"CREATE TABLE ENCOUNTERS(ENCOUNTER_ID CHAR(36) NOT NULL ,START CHAR(36) , STOP CHAR(36) , PATIENT CHAR(36), ORGANIZATION CHAR(36), PROVIDER CHAR(36),PAYER CHAR(36),ENCOUNTERCLASS CHAR(36),CODE CHAR(36),DESCRIPTION CHAR(100),BASE_ENCOUNTER_COST FLOAT,TOTAL_CLAIM_COST FLOAT,PAYER_COVERAGE FLOAT,REASONCODE CHAR(36),REASONDESCRIPTION CHAR(100), PRIMARY KEY (ENCOUNTER_ID))\";\
                                db2 \"CREATE TABLE CONDITIONS(START DATE , STOP DATE , PATIENT CHAR(36), ENCOUNTER CHAR(36) , CODE CHAR(36) , DESCRIPTION CHAR(100))\";\
                                db2 import from patients.csv of del skipcount 1 insert into db2inst1.patients;\
                                db2 import from encounters.csv of del skipcount 1 insert into db2inst1.encounters;\
                                db2 import from conditions.csv of del skipcount 1 insert into db2inst1.conditions;\
                                db2 connect reset;"
                        source ~/.bashrc && /bin/su -c "$command" - db2inst1
