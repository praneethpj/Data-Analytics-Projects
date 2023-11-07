-- Cleaning Data in MYSQL Queries
-----------------------------------------------------------------------

SELECT *
FROM EcommerceDB.salestbl


-----------------------------------------------------------------------
-- Standardise Date Format


ALTER TABLE EcommerceDB.salestbl
ADD UpdatedSaleDate DATE;

UPDATE EcommerceDB.salestbl
SET UpdatedSaleDate = DATE(SaleDate);

-- Verify the changes
SELECT UpdatedSaleDate, SaleDate
FROM EcommerceDB.salestbl;



-----------------------------------------------------------------------
-- Populate Property Address Data

UPDATE EcommerceDB.salestbl a
JOIN EcommerceDB.salestbl b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress);

-- Find rows with NULL PropertyAddress
SELECT PropertyAddress
FROM EcommerceDB.salestbl
WHERE PropertyAddress IS NULL;


-------------------------------------------------------------------------
-- Breaking out Full Address into individual Columns (Address, City, State)

--Property Address

ALTER TABLE EcommerceDB.salestbl
ADD PropertyAddressStreet NVARCHAR(255),
    PropertyAddressCity NVARCHAR(255);

UPDATE EcommerceDB.salestbl
SET PropertyAddressStreet = SUBSTRING_INDEX(PropertyAddress, ', ', 1),
    PropertyAddressCity = SUBSTRING_INDEX(PropertyAddress, ', ', -1);

-- Verify the changes
SELECT PropertyAddressStreet, PropertyAddressCity
FROM EcommerceDB.salestbl;


-- Owner Address

ALTER TABLE EcommerceDB.salestbl
ADD OwnerAddressStreet NVARCHAR(255),
    OwnerAddressCity NVARCHAR(255),
    OwnerAddressState NVARCHAR(255);

UPDATE EcommerceDB.salestbl
SET OwnerAddressStreet = PARSE_NAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerAddressCity = PARSE_NAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerAddressState = PARSE_NAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Verify the changes
SELECT OwnerAddressStreet, OwnerAddressCity, OwnerAddressState
FROM EcommerceDB.salestbl;



------------------------------------------------------------------------------
-- Change "Y" to "Yes" and "N" to "No" in the "Sold as Vacant" field



UPDATE EcommerceDB.salestbl
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- Verify the changes
SELECT DISTINCT SoldAsVacant
FROM EcommerceDB.salestbl;


	
-------------------------------------------------------------------------------
-- Remove Duplicates
 
 WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) row_num
    FROM EcommerceDB.salestbl
)

-- Delete duplicates
DELETE FROM RowNumCTE
WHERE row_num > 1;




----------------------------------------------------------------
-- Delete Unused Columns


ALTER TABLE EcommerceDB.salestbl
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress;
