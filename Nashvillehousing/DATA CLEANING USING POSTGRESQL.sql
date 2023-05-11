-- DATA CLEANING USING POSTGRESQL 
SELECT * FROM nashvillehousing;
Select count (distinct propertyaddress)
from nashvillehousing;

SELECT COUNT(*) FROM nashvillehousing
where ownername IS NULL;

-- populate property address data 
SELECT propertyaddress FROM nashvillehousing;
SELECT * FROM nashvillehousing
--WHERE propertyaddress IS NULL
ORDER BY parcelid;

-- I am using coalesce() function to replace the nulls
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b
    ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

-- updating the table with the changes made 

UPDATE nashvillehousing a
SET propertyaddress = (
    SELECT b.propertyaddress
    FROM nashvillehousing b
    WHERE a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
      AND b.propertyaddress IS NOT NULL
    LIMIT 1
)
WHERE propertyaddress IS NULL;

--Breaking out Propertyaddress into individual columns(Address, City)
SELECT propertyaddress FROM nashvillehousing;
SELECT 
SPLIT_PART (propertyaddress, ',', 1) AS property_address, 
SPLIT_PART (propertyaddress, ',', 2) AS property_city
FROM nashvillehousing;

-- Adding new columns and updating them 

ALTER TABLE nashvillehousing
ADD COLUMN property_address TEXT;

UPDATE nashvillehousing SET property_address = SPLIT_PART (propertyaddress, ',', 1);

ALTER TABLE nashvillehousing
ADD COLUMN property_city TEXT;

UPDATE nashvillehousing SET property_city = SPLIT_PART (propertyaddress, ',', 2);

--Breaking out Owneraddress into individual columns(Address, City, State)
SELECT owneraddress FROM nashvillehousing;
SELECT 
SPLIT_PART (owneraddress, ',', 1) AS owner_address, 
SPLIT_PART (owneraddress, ',', 2) AS owner_city,
SPLIT_PART (owneraddress, ',', 3) AS owner_state
FROM nashvillehousing;

-- Adding new columns and updating them into the table

ALTER TABLE nashvillehousing
ADD COLUMN owner_address TEXT;

UPDATE nashvillehousing SET owner_address = SPLIT_PART (owneraddress, ',', 1); 

ALTER TABLE nashvillehousing
ADD COLUMN owner_city TEXT;

UPDATE nashvillehousing SET owner_city = SPLIT_PART (owneraddress, ',', 2);

ALTER TABLE nashvillehousing
ADD COLUMN owner_state TEXT;

UPDATE nashvillehousing SET owner_state = SPLIT_PART (owneraddress, ',', 3);

-- Changing the Y & N to Yes & NO in 'Sold as vacant' field 
SELECT DISTINCT (soldasvacant), COUNT(soldasvacant)
FROM nashvillehousing
GROUP BY 1
ORDER BY 2;

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN soldasvacant = 'N' THEN 'No'
     ELSE soldasvacant
	 END 
FROM nashvillehousing;

-- Updating the table 
UPDATE nashvillehousing SET soldasvacant =
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant
	 END ;

-- Removing the duplicate rows using COMMON TABLE EXPRESSION  

WITH rowNUMCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress,saleprice, legalreference ORDER BY uniqueid) row_num
FROM public.nashvillehousing
),
duplicates AS (
SELECT parcelid, propertyaddress,saleprice, legalreference
	FROM rowNUMCTE
	WHERE row_num > 1
)
DELETE 
FROM nashvillehousing
WHERE (parcelid, propertyaddress,saleprice, legalreference) 
IN (SELECT parcelid, propertyaddress,saleprice, legalreference FROM duplicates);

--checking if the code worked and the duplicates have been deleted 
SELECT * FROM duplicates
WHERE row_num > 1;

-- my schema_name
SELECT table_name,table_schema 
FROM information_schema.tables
WHERE table_name = 'nashvillehousing';

-- Delete unused columns 
-- in this case I am dropping columns; owneraddress taxdistrict, propertyaddress
SELECT * FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

