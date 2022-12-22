SELECT *
FROM [Nashville Housing]


-- Standerdize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [Portfolio _Project].dbo.[Nashville Housing]


-- Update the SaleDate column to the standardized date format
-- first create an empty column (for "Date" data type)
ALTER TABLE [Nashville Housing] 
ADD SaleDateConverted Date;

-- and update the  new column based on the SaleDate column (standardized)
UPDATE [Nashville Housing]
SET SaleDateConverted = CONVERT(Date, SaleDate)
-------------------------------------------------------------------------------


SELECT PropertyAddress
FROM [Nashville Housing]
-- observe that some rows of the property address column is null
-- also observe that some of these rows share the same parcel ID (consequently the same address) with other rows that are not null
-- the isnull function replace a field with another field.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- update using the isnull function
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- check the update
SELECT *
FROM [Nashville Housing]
-------------------------------------------------------------------------------


SELECT PropertyAddress
FROM [Nashville Housing]
-- note that in the property address column, the address and the city are separated by a column, so we extract both.
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
-- i.e get a substring from Property address, starting from position 1, to the position of the comma(the charindex funtion helps us get the position of the comma)
-- so the substring that'll be pulled from each row is relative, it depends on the position of the comma(thanks to charindex)
-- but we don't want the comma to be pulled along, so we add -1, so it'll pull from the position of the comma - 1, i.e minus the comma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
-- here, unlike the first one, we'll pull the substring starting from the charindex of ',' and so as to not include the comma, we move one step forward (+1)
-- and we stop at the number that correspond to the lenght(LEN) of the string i.e till the end
FROM [Nashville Housing]


-- Let's add the columns to input our new strings to the table
ALTER TABLE [Nashville Housing]
Add City NVARCHAR(255)

ALTER TABLE [Nashville Housing]
Add Address NVARCHAR(255)

-- now, update the new strings into the column
UPDATE [Nashville Housing]
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

UPDATE [Nashville Housing]
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

----------------------------------------------------------------------------------------------------------

-- note the OwnerAddress Column contains the Address, City and State all separated by a comma. 
SELECT OwnerAddress
FROM [Nashville Housing]

-- So we extract them using Parsename function, which extract strings separated by 'Dot'
-- So we Replace the ',' with '.' before using the parsename function
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
-- note parsename starts from the 'Right'
FROM [Nashville Housing]

-- Let's add the columns to input our new strings to the table
ALTER TABLE [Nashville Housing]
Add Owner_Address NVARCHAR(255)

ALTER TABLE [Nashville Housing]
Add Owner_City NVARCHAR(255)

ALTER TABLE [Nashville Housing]
Add Owner_State NVARCHAR(255)

-- now, update the new strings into the column
UPDATE [Nashville Housing]
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE [Nashville Housing]
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE [Nashville Housing]
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
------------------------------------------------------------------------------------------------


-- note in the SOldAsvacant column some rows used 'N' and 'y' instead of No and yes respectively
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

-- so we change 'N' to No and 'Y' to Yes
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
-------------------------------------------------------------------------------


--- Remove duplicates

WITH rownum_CTE AS(
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Nashville Housing])
DELETE 
FROM rownum_CTE
WHERE row_num > 1
------------------------------------------------------------------------------------------------

-- Let's Drop the columns we'll not be using
ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- Let's view the updated table
SELECT *
FROM [Nashville Housing]
