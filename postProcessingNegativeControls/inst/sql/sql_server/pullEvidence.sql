SELECT *
INTO #TEMP_STORE_DATA
FROM (

  /*PULL ALL PMIDS THAT ARE IN A DESCENDANT RELATIONSHIP TO THE OUTCOME OF INTEREST*/
	SELECT DISTINCT
	  '@adeType'  AS DATA_TYPE,
	  'DESCENDANT' AS MAPPING_TYPE,
		u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
		u.CONCEPT_NAME AS OUTCOME_OF_INTEREST_CONCEPT_NAME,
		{@outcomeOfInterest == 'condition'}?{
		  a.SOURCE_CODE_2       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_2  AS SOURCE_CODE_NAME,
		}
		{@outcomeOfInterest == 'drug'}?{
		  a.SOURCE_CODE_1       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_1  AS SOURCE_CODE_NAME,
		}
		a.UNIQUE_IDENTIFIER,
		a.UNIQUE_IDENTIFIER_TYPE
	FROM @conceptUniverseData  u
		JOIN @vocabulary.CONCEPT_ANCESTOR ca
			ON ca.ANCESTOR_CONCEPT_ID = u.CONCEPT_ID
		JOIN @adeData a
			{@outcomeOfInterest == 'condition'}?{
			  ON a.CONCEPT_ID_2 = ca.DESCENDANT_CONCEPT_ID
			  AND a.CONCEPT_ID_2 != ca.ANCESTOR_CONCEPT_ID
			}
			{@outcomeOfInterest == 'drug'}?{
			  ON a.CONCEPT_ID_1 = ca.DESCENDANT_CONCEPT_ID
			  AND a.CONCEPT_ID_1 != ca.ANCESTOR_CONCEPT_ID
			}
	WHERE
	  {@outcomeOfInterest == 'condition'}?{CONCEPT_ID_1}
	  {@outcomeOfInterest == 'drug'}?{CONCEPT_ID_2}
	  IN (
		SELECT CONCEPT_ID
		FROM @vocabulary.CONCEPT
		WHERE CONCEPT_ID IN (@conceptsOfInterest)
		UNION ALL
		SELECT DESCENDANT_CONCEPT_ID
		FROM @vocabulary.CONCEPT_ANCESTOR
		WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
  )

	UNION ALL

  /*PULL ALL PMIDS THAT ARE IN A EXACT RELATIONSHIP TO THE OUTCOME OF INTEREST*/
	SELECT DISTINCT
	  '@adeType'  AS DATA_TYPE,
	  'EXACT' AS MAPPING_TYPE,
		u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
		u.CONCEPT_NAME AS OUTCOME_OF_INTEREST_CONCEPT_NAME,
		{@outcomeOfInterest == 'condition'}?{
		  a.SOURCE_CODE_2       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_2  AS SOURCE_CODE_NAME,
		}
		{@outcomeOfInterest == 'drug'}?{
		  a.SOURCE_CODE_1       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_1  AS SOURCE_CODE_NAME,
		}
		a.UNIQUE_IDENTIFIER,
		a.UNIQUE_IDENTIFIER_TYPE
	FROM @conceptUniverseData  u
		JOIN @adeData a
		  {@outcomeOfInterest == 'condition'}?{
			  ON a.CONCEPT_ID_2 = u.CONCEPT_ID
			}
			{@outcomeOfInterest == 'drug'}?{
			  ON a.CONCEPT_ID_1 = u.CONCEPT_ID
			}
	WHERE
	  {@outcomeOfInterest == 'condition'}?{CONCEPT_ID_1}
	  {@outcomeOfInterest == 'drug'}?{CONCEPT_ID_2}
	  IN (
		SELECT CONCEPT_ID
		FROM @vocabulary.CONCEPT
		WHERE CONCEPT_ID IN (@conceptsOfInterest)
		UNION ALL
		SELECT DESCENDANT_CONCEPT_ID
		FROM @vocabulary.CONCEPT_ANCESTOR
		WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
	)

	UNION ALL

  /*PULL ALL PMIDS THAT ARE IN A PARENT RELATIONSHIP TO THE OUTCOME OF INTEREST*/
	SELECT DISTINCT
	  '@adeType'  AS DATA_TYPE,
	  'PARENT' AS MAPPING_TYPE,
		u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
		u.CONCEPT_NAME AS OUTCOME_OF_INTEREST_CONCEPT_NAME,
		{@outcomeOfInterest == 'condition'}?{
		  a.SOURCE_CODE_2       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_2  AS SOURCE_CODE_NAME,
		}
		{@outcomeOfInterest == 'drug'}?{
		  a.SOURCE_CODE_1       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_1  AS SOURCE_CODE_NAME,
		}
		a.UNIQUE_IDENTIFIER,
		a.UNIQUE_IDENTIFIER_TYPE
	FROM @conceptUniverseData  u
		JOIN @vocabulary.CONCEPT_RELATIONSHIP cr
  		  ON cr.CONCEPT_ID_1 = u.CONCEPT_ID
			  AND UPPER(cr.RELATIONSHIP_ID) = 'IS A'
		JOIN @adeData a
			{@outcomeOfInterest == 'condition'}?{
  		  ON a.CONCEPT_ID_2 = cr.CONCEPT_ID_2
			  AND a.CONCEPT_ID_2 != cr.CONCEPT_ID_1
  		}
  		{@outcomeOfInterest == 'drug'}?{
  		  ON a.CONCEPT_ID_1 = cr.CONCEPT_ID_2
			  AND a.CONCEPT_ID_1 != cr.CONCEPT_ID_1
  		}
	WHERE
	  {@outcomeOfInterest == 'condition'}?{a.CONCEPT_ID_1}
	  {@outcomeOfInterest == 'drug'}?{a.CONCEPT_ID_2}
	  IN (
		SELECT CONCEPT_ID
		FROM @vocabulary.CONCEPT
		WHERE CONCEPT_ID IN (@conceptsOfInterest)
		UNION ALL
		SELECT DESCENDANT_CONCEPT_ID
		FROM @vocabulary.CONCEPT_ANCESTOR
		WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
	)


	UNION ALL

  /*PULL ALL PMIDS THAT ARE IN A ANCESTOR RELATIONSHIP TO THE OUTCOME OF INTEREST*/
	SELECT DISTINCT
	  '@adeType'  AS DATA_TYPE,
	  'ANCESTOR' AS MAPPING_TYPE,
		u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
		u.CONCEPT_NAME AS OUTCOME_OF_INTEREST_CONCEPT_NAME,
		{@outcomeOfInterest == 'condition'}?{
		  a.SOURCE_CODE_2       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_2  AS SOURCE_CODE_NAME,
		}
		{@outcomeOfInterest == 'drug'}?{
		  a.SOURCE_CODE_1       AS SOURCE_CODE,
		  a.SOURCE_CODE_NAME_1  AS SOURCE_CODE_NAME,
		}
		a.UNIQUE_IDENTIFIER,
		a.UNIQUE_IDENTIFIER_TYPE
	FROM @conceptUniverseData  u
		JOIN @vocabulary.CONCEPT_ANCESTOR ca
			ON ca.DESCENDANT_CONCEPT_ID = u.CONCEPT_ID
		JOIN @adeData a
			{@outcomeOfInterest == 'condition'}?{
			  ON a.CONCEPT_ID_2 = ca.ANCESTOR_CONCEPT_ID
			  AND a.CONCEPT_ID_2 != ca.DESCENDANT_CONCEPT_ID
			}
			{@outcomeOfInterest == 'drug'}?{
			  ON a.CONCEPT_ID_1 = ca.ANCESTOR_CONCEPT_ID
		  	AND a.CONCEPT_ID_1 != ca.DESCENDANT_CONCEPT_ID
			}
	WHERE
	  {@outcomeOfInterest == 'condition'}?{CONCEPT_ID_1}
	  {@outcomeOfInterest == 'drug'}?{CONCEPT_ID_2}
	  IN (
		SELECT CONCEPT_ID
		FROM @vocabulary.CONCEPT
		WHERE CONCEPT_ID IN (@conceptsOfInterest)
		UNION ALL
		SELECT DESCENDANT_CONCEPT_ID
		FROM @vocabulary.CONCEPT_ANCESTOR
		WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
	)

) z;

INSERT INTO @storeData (DATA_TYPE,MAPPING_TYPE,OUTCOME_OF_INTEREST_CONCEPT_ID, OUTCOME_OF_INTEREST_CONCEPT_NAME, SOURCE_CODE, SOURCE_CODE_NAME, UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE)
SELECT DATA_TYPE,MAPPING_TYPE,OUTCOME_OF_INTEREST_CONCEPT_ID, OUTCOME_OF_INTEREST_CONCEPT_NAME, SOURCE_CODE, SOURCE_CODE_NAME, UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE
FROM #TEMP_STORE_DATA;

DROP TABLE #TEMP_STORE_DATA;
