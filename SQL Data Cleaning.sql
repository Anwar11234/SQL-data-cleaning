SELECT * 
FROM NashvilleHousing;
-------------------------------------------------------------------------------------------------------------
-- Converting SaleDate from Datetime to only Date 
SELECT SaleDate , CONVERT(DATE , SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(DATE , SaleDate);


SELECT SaleDateConverted , saleDate 
FROM NashvilleHousing;

-------------------------------------------------------------------------------------------------------------

-- Populate Property Address data 

SELECT ParcelID , PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT NH1.ParcelID , NH1.PropertyAddress , NH2.ParcelID , NH2.PropertyAddress , ISNULL(NH1.PropertyAddress , NH2.PropertyAddress)
FROM NashvilleHousing NH1 
JOIN NashvilleHousing NH2
ON NH1.ParcelID = NH2.ParcelID
AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

UPDATE NH1 
SET NH1.PropertyAddress =  ISNULL(NH1.PropertyAddress , NH2.PropertyAddress)
FROM NashvilleHousing NH1 
JOIN NashvilleHousing NH2
ON NH1.ParcelID = NH2.ParcelID
AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

SELECT COUNT(*) 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

-------------------------------------------------------------------------------------------------------------

-- Break out Property Address into individual columns (Address , City)
SELECT SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) - 1) AS Adress , 
SUBSTRING(PropertyAddress ,CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) - 1);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress));


-- Break out Owner Address into individual columns (Address , City , State)
SELECT PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3),
	   PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2),
	   PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255); 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3);

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1);

SELECT * FROM NashvilleHousing
-------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant ,  COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant , 
	CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END

-------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with rowNumCTE AS
(
	SELECT * ,
	ROW_NUMBER() OVER (PARTITION BY PropertyAddress, parcelID , SaleDate , SalePrice , LegalReference ORDER BY UniqueID) row_num
	FROM NashvilleHousing
)
DELETE
FROM rowNumCTE
WHERE row_num > 1