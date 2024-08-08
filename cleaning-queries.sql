USE NashvilleHousing;

-- Data Cleaning

-- Standardize the Date Format
ALTER TABLE Housing
ALTER COLUMN saledate DATE;

SELECT SaleDate
FROM Housing;

-- Property Address Data

-- Update missing data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL;


-- Separate addresses into multiple columns
-- PropertyAddress

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
FROM Housing;

ALTER TABLE Housing
Add PropertyAddressStreet Nvarchar(255);

ALTER TABLE Housing
Add PropertyAddressCity Nvarchar(255);

UPDATE Housing
Set PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

UPDATE Housing
Set PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress));


--OwnerAddress

ALTER TABLE Housing
Add OwnerAddressStreet Nvarchar(255);

ALTER TABLE Housing
Add OwnerAddressCity Nvarchar(255);

ALTER TABLE Housing
Add OwnerAddressState Nvarchar(255);

UPDATE Housing
Set OwnerAddressStreet = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3));

UPDATE Housing
Set OwnerAddressCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2));

UPDATE Housing
Set OwnerAddressState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1));

-- Convert values from Y and N to Yes and No in *Sold as Vacant* field

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;


-- Remove duplicates

WITH DupesCTE
AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM Housing
)
DELETE
FROM DupesCTE
WHERE row_num > 1;

-- Delete unnecessary columns

ALTER TABLE Housing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

-- Finished cleaning
SELECT *
FROM Housing;