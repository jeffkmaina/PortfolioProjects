-- Cleaning Data in SQL queries

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

--Standardize sale date

SELECT SaleDate
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date

--Populate Property Address

SELECT PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing AS a
JOIN Portfolio_Project.dbo.NashvilleHousing AS b
	ON a.ParcelID = B.ParcelID
	AND a.UniqueID <> B.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing AS a
JOIN Portfolio_Project.dbo.NashvilleHousing AS b
	ON a.ParcelID = B.ParcelID
	AND a.UniqueID <> B.UniqueID
WHERE a.PropertyAddress IS NULL


--Breaking out Address into Individual columns(Address, City, State) Using substrings

SELECT PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing


SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD  PropertySplitAddress Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD  PropertySplitCity Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing


--Splitting Owner Address using PARSENAME

SELECT OwnerAddress
FROM Portfolio_Project.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD  OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD  OwnerSplitCity Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD  OwnerSplitState Nvarchar(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing


--Change Y and N to Yes and No in 'Sold as Vacant" column


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project.dbo.NashvilleHousing
GROUP BY(SoldAsVacant)
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					   WHEN SoldAsVacant = 'N' THEN 'No'
					   ELSE SoldAsVacant
					   END

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM Portfolio_Project.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate