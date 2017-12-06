/*@vocabSchema*/
IF OBJECT_ID('@tableName', 'U') IS NOT NULL DROP TABLE @tableName;

CREATE TABLE @tableName (
	ID SERIAL,
	SOURCE_ID	VARCHAR(20),
	SOURCE_CODE_1	VARCHAR(50),
	SOURCE_CODE_TYPE_1	VARCHAR(55),
	SOURCE_CODE_NAME_1	VARCHAR(255),
	CONCEPT_ID_1	INT,
	RELATIONSHIP_ID	VARCHAR(20),
	SOURCE_CODE_2	VARCHAR(50),
	SOURCE_CODE_TYPE_2	VARCHAR(55),
	SOURCE_CODE_NAME_2	VARCHAR(255),
	UNIQUE_IDENTIFIER	VARCHAR(50),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(50),
	CASE_COUNT	BIGINT,
	PRR	DECIMAL(20, 5),
	PRR_95_PERCENT_LOWER_CONFIDENCE_LIMIT	DECIMAL(20, 5),
	PRR_95_PERCENT_UPPER_CONFIDENCE_LIMIT	DECIMAL(20, 5),
	ROR	DECIMAL(20, 5),
	ROR_95_PERCENT_LOWER_CONFIDENCE_LIMIT	DECIMAL(20, 5),
	ROR_95_PERCENT_UPPER_CONFIDENCE_LIMIT	DECIMAL(20, 5),
	COUNT_A	BIGINT,
	COUNT_B	BIGINT,
	COUNT_C	BIGINT,
	COUNT_D	BIGINT,
	CHI_SQUARE  DECIMAL(20,5)
);

INSERT INTO @tableName (SOURCE_ID, SOURCE_CODE_1, SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, CONCEPT_ID_1, RELATIONSHIP_ID,
	SOURCE_CODE_2, SOURCE_CODE_TYPE_2, SOURCE_CODE_NAME_2, UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE,
	CASE_COUNT, PRR, PRR_95_PERCENT_LOWER_CONFIDENCE_LIMIT, PRR_95_PERCENT_UPPER_CONFIDENCE_LIMIT, ROR,
	ROR_95_PERCENT_LOWER_CONFIDENCE_LIMIT, ROR_95_PERCENT_UPPER_CONFIDENCE_LIMIT, COUNT_A, COUNT_B, COUNT_C, COUNT_D, CHI_SQUARE)
SELECT '@sourceId' AS SOURCE_ID,
	s.DRUG_CONCEPT_ID AS SOURCE_CODE_1, /*DRUG COMES AS STANDARD*/
	'OMOP CONCEPT_ID' AS SOURCE_CODE_TYPE_1,
	c.CONCEPT_NAME AS SOURCE_CODE_NAME_1,
	c.CONCEPT_ID AS CONCEPT_ID_1,
	'Has Adverse Event' AS RELATIONSHIP_ID,
	s.OUTCOME_CONCEPT_ID AS SOURCE_CODE_2, /*CONDITION COMES AS NON-STANDARD*/
	'OMOP CONCEPT_ID' AS SOURCE_CODE_TYPE_2,
	c2.CONCEPT_NAME AS SOURCE_CODE_NAME_2,
	CONCAT(s.DRUG_CONCEPT_ID,'-',s.OUTCOME_CONCEPT_ID) AS UNIQUE_IDENTIFIER,
	'DRUG_COCNEPT_ID-OUTCOME_CONCEPT_ID' AS UNIQUE_IDENTIFIER_TYPE,
	CASE_COUNT,
	PRR,
	PRR_95_PERCENT_LOWER_CONFIDENCE_LIMIT,
	PRR_95_PERCENT_UPPER_CONFIDENCE_LIMIT,
	ROR,
	ROR_95_PERCENT_LOWER_CONFIDENCE_LIMIT,
	ROR_95_PERCENT_UPPER_CONFIDENCE_LIMIT,
	ct.COUNT_A,
	ct.COUNT_B,
	ct.COUNT_C,
	ct.COUNT_D,
	(ct.COUNT_A*ct.COUNT_D-ct.COUNT_B*ct.COUNT_C)*(ct.COUNT_A*ct.COUNT_D-ct.COUNT_B*ct.COUNT_C)*(ct.COUNT_A+ct.COUNT_B+ct.COUNT_C+ct.COUNT_D)/((ct.COUNT_A+ct.COUNT_B)*(ct.COUNT_C+ct.COUNT_D)*(ct.COUNT_B+ct.COUNT_D)*(ct.COUNT_A+ct.COUNT_C)) AS CHI_SQUARE
FROM @sourceSchema.standard_drug_outcome_statistics s
	LEFT OUTER JOIN @vocabSchema.CONCEPT c
		ON c.CONCEPT_ID = s.DRUG_CONCEPT_ID
	LEFT OUTER JOIN @vocabSchema.CONCEPT c2
		ON c2.CONCEPT_ID = s.OUTCOME_CONCEPT_ID
	LEFT OUTER JOIN @sourceSchema.standard_drug_outcome_contingency_table ct
		ON ct.DRUG_CONCEPT_ID = s.DRUG_CONCEPT_ID
		AND ct.OUTCOME_CONCEPT_ID = s.OUTCOME_CONCEPT_ID;

CREATE INDEX IDX_@sourceId_UNIQUE_IDENTIFIER_CONCEPT_ID_1_SOURCE_CODE_2 ON @tableName (UNIQUE_IDENTIFIER, CONCEPT_ID_1, SOURCE_CODE_2)
