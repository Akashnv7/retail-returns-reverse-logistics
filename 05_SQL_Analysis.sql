USE RetailReturnsAnalysis;
GO

/* =====================================================
   RETAIL RETURNS & REVERSE LOGISTICS OPTIMIZATION
   SQL ANALYSIS
   ===================================================== */
/* =====================================================
   STEP 1 — Overall Transaction & Cancellation KPI
   ===================================================== */

SELECT
    COUNT(*) AS Total_Transactions,

    SUM(CASE
        WHEN Cancellation_Flag = 'Yes' THEN 1
        ELSE 0
    END) AS Cancelled_Transactions,

    CAST(
        100.0 * SUM(CASE
            WHEN Cancellation_Flag = 'Yes' THEN 1
            ELSE 0
        END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Cancellation_Rate
FROM
(
    SELECT *
    FROM dbo.[2009]

    UNION ALL

    SELECT *
    FROM dbo.year2010
) AS RetailData;
/* =====================================================
   STEP 2 — Year-wise Cancellation Analysis
   ===================================================== */

SELECT
    '2009-2010' AS Year_Period,
    COUNT(*) AS Total_Transactions,
    SUM(CASE
        WHEN Cancellation_Flag = 'Yes' THEN 1
        ELSE 0
    END) AS Cancelled_Transactions,
    CAST(
        100.0 * SUM(CASE
            WHEN Cancellation_Flag = 'Yes' THEN 1
            ELSE 0
        END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Cancellation_Rate
FROM dbo.[2009]

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    COUNT(*) AS Total_Transactions,
    SUM(CASE
        WHEN Cancellation_Flag = 'Yes' THEN 1
        ELSE 0
    END) AS Cancelled_Transactions,
    CAST(
        100.0 * SUM(CASE
            WHEN Cancellation_Flag = 'Yes' THEN 1
            ELSE 0
        END) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Cancellation_Rate
FROM dbo.year2010;
/* ============================================================
   STEP 3 — MONTHLY CANCELLATION TREND
   Business Question:
   Which months have the highest cancellation activity?
   ============================================================ */

SELECT
    Month,
    COUNT(*) AS Cancelled_Transactions

FROM
(
    SELECT Month
    FROM dbo.[2009]
    WHERE Cancellation_Flag = 'Yes'

    UNION ALL

    SELECT Month
    FROM dbo.year2010
    WHERE Cancellation_Flag = 'Yes'
) AS MonthlyData

WHERE Month IS NOT NULL
  AND LTRIM(RTRIM(Month)) <> ''

GROUP BY Month
ORDER BY Month;

/* ============================================================
   STEP 4 — TOP 10 PRODUCTS BY CANCELLATION COUNT
   Business Question:
   Which products have the highest number of cancellations?
   ============================================================ */

SELECT TOP 10
    Description,
    COUNT(*) AS Cancellation_Count

FROM
(
    SELECT Description
    FROM dbo.[2009]
    WHERE Cancellation_Flag = 'Yes'

    UNION ALL

    SELECT Description
    FROM dbo.year2010
    WHERE Cancellation_Flag = 'Yes'
) AS ProductData

WHERE Description IS NOT NULL
  AND LTRIM(RTRIM(Description)) <> ''

GROUP BY Description
ORDER BY Cancellation_Count DESC;
/* ============================================================
   STEP 5 — TOP 10 COUNTRIES BY CANCELLATION COUNT
   Business Question:
   Which countries have the highest cancellation activity?
   ============================================================ */

SELECT TOP 10
    Country,
    COUNT(*) AS Cancellation_Count

FROM
(
    SELECT Country
    FROM dbo.[2009]
    WHERE Cancellation_Flag = 'Yes'

    UNION ALL

    SELECT Country
    FROM dbo.year2010
    WHERE Cancellation_Flag = 'Yes'
) AS CountryData

WHERE Country IS NOT NULL
  AND LTRIM(RTRIM(Country)) <> ''

GROUP BY Country
ORDER BY Cancellation_Count DESC;

/* ============================================================
   STEP 6 — TOTAL TRANSACTION VALUE
   Business Question:
   What is the total transaction value across both years?
   ============================================================ */

SELECT
    SUM(
        TRY_CONVERT(DECIMAL(18,4), TransactionValue)
    ) AS Total_Transaction_Value

FROM
(
    SELECT TransactionValue
    FROM dbo.[2009]

    UNION ALL

    SELECT Transaction_value
    FROM dbo.year2010
) AS ValueData;
/* ============================================================
   STEP 7 — CANCELLATION TRANSACTION VALUE
   Business Question:
   What transaction value is associated with cancellations?
   ============================================================ */

SELECT
    SUM(
        TRY_CONVERT(DECIMAL(18,4), TransactionValue)
    ) AS Cancellation_Transaction_Value

FROM
(
    SELECT TransactionValue
    FROM dbo.[2009]
    WHERE Cancellation_Flag = 'Yes'

    UNION ALL

    SELECT Transaction_value
    FROM dbo.year2010
    WHERE Cancellation_Flag = 'Yes'
) AS CancellationValueData;
/* ============================================================
   STEP 8 — YEAR-WISE TRANSACTION VALUE
   ============================================================ */

SELECT
    '2009-2010' AS Year_Period,
    SUM(TRY_CONVERT(DECIMAL(18,4), TransactionValue))
        AS Transaction_Value
FROM dbo.[2009]

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    SUM(TRY_CONVERT(DECIMAL(18,4), Transaction_value))
        AS Transaction_Value
FROM dbo.year2010;
/* ============================================================
   STEP 9 — YEAR-WISE CANCELLATION TRANSACTION VALUE
   ============================================================ */

SELECT
    '2009-2010' AS Year_Period,
    SUM(TRY_CONVERT(DECIMAL(18,4), TransactionValue))
        AS Cancellation_Value
FROM dbo.[2009]
WHERE Cancellation_Flag = 'Yes'

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    SUM(TRY_CONVERT(DECIMAL(18,4), Transaction_value))
        AS Cancellation_Value
FROM dbo.year2010
WHERE Cancellation_Flag = 'Yes';
/* ============================================================
   STEP 10 — CANCELLATION COUNT BY PRODUCT
   ============================================================ */

SELECT
    Description,
    COUNT(*) AS Cancellation_Count
FROM
(
    SELECT Description
    FROM dbo.[2009]
    WHERE Cancellation_Flag = 'Yes'

    UNION ALL

    SELECT Description
    FROM dbo.year2010
    WHERE Cancellation_Flag = 'Yes'
) AS ProductCancellationData
WHERE Description IS NOT NULL
  AND LTRIM(RTRIM(Description)) <> ''
GROUP BY Description
ORDER BY Cancellation_Count DESC;
/* ============================================================
   STEP 11 — CANCELLATION COUNT BY COUNTRY
   ============================================================ */

SELECT
    Country,
    COUNT(*) AS Cancellation_Count
FROM
(
    SELECT Country
    FROM dbo.[2009]
    WHERE Cancellation_Flag = 'Yes'

    UNION ALL

    SELECT Country
    FROM dbo.year2010
    WHERE Cancellation_Flag = 'Yes'
) AS CountryCancellationData
WHERE Country IS NOT NULL
  AND LTRIM(RTRIM(Country)) <> ''
GROUP BY Country
ORDER BY Cancellation_Count DESC;
/* ============================================================
   STEP 12 — TOP 20 CANCELLED STOCK CODES
   ============================================================ */

SELECT TOP 20
    StockCode,
    COUNT(*) AS Cancellation_Count
FROM
(
    SELECT StockCode
    FROM dbo.[2009]
    WHERE Cancellation_Flag = 'Yes'

    UNION ALL

    SELECT StockCode
    FROM dbo.year2010
    WHERE Cancellation_Flag = 'Yes'
) AS StockCancellationData
WHERE StockCode IS NOT NULL
  AND LTRIM(RTRIM(StockCode)) <> ''
GROUP BY StockCode
ORDER BY Cancellation_Count DESC;
/* ============================================================
   STEP 13 — NEGATIVE QUANTITY ANALYSIS
   ============================================================ */

SELECT
    COUNT(*) AS Negative_Quantity_Transactions
FROM
(
    SELECT Quantity
    FROM dbo.[2009]

    UNION ALL

    SELECT Quantity
    FROM dbo.year2010
) AS QuantityData
WHERE Quantity < 0;
/* ============================================================
   STEP 14 — NEGATIVE QUANTITY BY YEAR
   ============================================================ */

SELECT
    '2009-2010' AS Year_Period,
    COUNT(*) AS Negative_Quantity_Transactions
FROM dbo.[2009]
WHERE Quantity < 0

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    COUNT(*) AS Negative_Quantity_Transactions
FROM dbo.year2010
WHERE Quantity < 0;
/* ============================================================
   STEP 15 — MISSING CUSTOMER IDs
   ============================================================ */

SELECT
    '2009-2010' AS Year_Period,
    SUM(
        CASE
            WHEN Customer_ID IS NULL
              OR LTRIM(RTRIM(Customer_ID)) = ''
            THEN 1
            ELSE 0
        END
    ) AS Missing_Customer_IDs
FROM dbo.[2009]

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    SUM(
        CASE
            WHEN Customer_ID IS NULL
              OR LTRIM(RTRIM(Customer_ID)) = ''
            THEN 1
            ELSE 0
        END
    ) AS Missing_Customer_IDs
FROM dbo.year2010;
/* ============================================================
   STEP 16 — MISSING DESCRIPTIONS
   ============================================================ */

SELECT
    '2009-2010' AS Year_Period,
    SUM(
        CASE
            WHEN Description IS NULL
              OR LTRIM(RTRIM(Description)) = ''
            THEN 1
            ELSE 0
        END
    ) AS Missing_Descriptions
FROM dbo.[2009]

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    SUM(
        CASE
            WHEN Description IS NULL
              OR LTRIM(RTRIM(Description)) = ''
            THEN 1
            ELSE 0
        END
    ) AS Missing_Descriptions
FROM dbo.year2010;
/* ============================================================
   STEP 17 — CANCELLATION RATE BY COUNTRY
   ============================================================ */

SELECT TOP 20
    Country,
    COUNT(*) AS Total_Transactions,

    SUM(
        CASE
            WHEN Cancellation_Flag = 'Yes' THEN 1
            ELSE 0
        END
    ) AS Cancelled_Transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Cancellation_Flag = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Cancellation_Rate

FROM
(
    SELECT Country, Cancellation_Flag
    FROM dbo.[2009]

    UNION ALL

    SELECT Country, Cancellation_Flag
    FROM dbo.year2010
) AS CountryRateData

WHERE Country IS NOT NULL
  AND LTRIM(RTRIM(Country)) <> ''

GROUP BY Country

HAVING COUNT(*) >= 100

ORDER BY Cancellation_Rate DESC;
/* ============================================================
   STEP 18 — CANCELLATION RATE BY PRODUCT
   ============================================================ */

SELECT TOP 20
    Description,
    COUNT(*) AS Total_Transactions,

    SUM(
        CASE
            WHEN Cancellation_Flag = 'Yes' THEN 1
            ELSE 0
        END
    ) AS Cancelled_Transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Cancellation_Flag = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Cancellation_Rate

FROM
(
    SELECT Description, Cancellation_Flag
    FROM dbo.[2009]

    UNION ALL

    SELECT Description, Cancellation_Flag
    FROM dbo.year2010
) AS ProductRateData

WHERE Description IS NOT NULL
  AND LTRIM(RTRIM(Description)) <> ''

GROUP BY Description

HAVING COUNT(*) >= 20

ORDER BY Cancellation_Rate DESC;
/* ============================================================
   STEP 19 — INVALID INVOICE DATE VALUES
   ============================================================ */

SELECT
    '2009-2010' AS Year_Period,
    COUNT(*) AS Invalid_InvoiceDate_Values
FROM dbo.[2009]
WHERE TRY_CONVERT(DATETIME, InvoiceDate, 105) IS NULL

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    COUNT(*) AS Invalid_InvoiceDate_Values
FROM dbo.year2010
WHERE TRY_CONVERT(DATETIME, InvoiceDate, 105) IS NULL;
/* ============================================================
   STEP 20 — INVALID TRANSACTION VALUE CHECK
   ============================================================ */

SELECT
    '2009-2010' AS Year_Period,
    COUNT(*) AS Invalid_Transaction_Values
FROM dbo.[2009]
WHERE TransactionValue IS NOT NULL
  AND LTRIM(RTRIM(TransactionValue)) <> ''
  AND TRY_CONVERT(DECIMAL(18,4), TransactionValue) IS NULL

UNION ALL

SELECT
    '2010-2011' AS Year_Period,
    COUNT(*) AS Invalid_Transaction_Values
FROM dbo.year2010
WHERE Transaction_value IS NOT NULL
  AND LTRIM(RTRIM(Transaction_value)) <> ''
  AND TRY_CONVERT(DECIMAL(18,4), Transaction_value) IS NULL;
  /* ============================================================
   STEP 21 — CANCELLATION RATE BY MONTH
   Business Question:
   Which months have higher cancellation rates?
   ============================================================ */

SELECT
    Month,

    COUNT(*) AS Total_Transactions,

    SUM(
        CASE
            WHEN Cancellation_Flag = 'Yes' THEN 1
            ELSE 0
        END
    ) AS Cancelled_Transactions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Cancellation_Flag = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Cancellation_Rate

FROM
(
    SELECT
        Month,
        Cancellation_Flag
    FROM dbo.[2009]

    UNION ALL

    SELECT
        Month,
        Cancellation_Flag
    FROM dbo.year2010
) AS MonthlyData

WHERE Month IS NOT NULL
  AND LTRIM(RTRIM(Month)) <> ''

GROUP BY Month

ORDER BY Month;
/* ============================================================
   STEP 22 — TOP PRODUCTS BY CANCELLATION VALUE
   Business Question:
   Which products have the highest transaction value
   associated with cancellations?
   ============================================================ */

SELECT TOP 20
    Description,

    SUM(
        TRY_CONVERT(DECIMAL(18,4), TransactionValue)
    ) AS Cancellation_Value

FROM dbo.[2009]

WHERE Cancellation_Flag = 'Yes'
  AND Description IS NOT NULL
  AND LTRIM(RTRIM(Description)) <> ''

GROUP BY Description

UNION ALL

SELECT TOP 20
    Description,

    SUM(
        TRY_CONVERT(DECIMAL(18,4), Transaction_value)
    ) AS Cancellation_Value

FROM dbo.year2010

WHERE Cancellation_Flag = 'Yes'
  AND Description IS NOT NULL
  AND LTRIM(RTRIM(Description)) <> ''

GROUP BY Description;
/* ============================================================
   STEP 23 — CANCELLATION FLAG VS NEGATIVE QUANTITY
   Business Question:
   How closely do cancellation records correspond with
   negative-quantity transactions?
   ============================================================ */

SELECT
    Cancellation_Flag,

    CASE
        WHEN Quantity < 0 THEN 'Negative Quantity'
        ELSE 'Zero/Positive Quantity'
    END AS Quantity_Type,

    COUNT(*) AS Transaction_Count

FROM
(
    SELECT
        Cancellation_Flag,
        Quantity
    FROM dbo.[2009]

    UNION ALL

    SELECT
        Cancellation_Flag,
        Quantity
    FROM dbo.year2010
) AS RetailData

GROUP BY
    Cancellation_Flag,
    CASE
        WHEN Quantity < 0 THEN 'Negative Quantity'
        ELSE 'Zero/Positive Quantity'
    END

ORDER BY
    Cancellation_Flag,
    Quantity_Type;
    