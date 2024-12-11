/*

Data Cleaning in SQL Queries

*/

Select *
From NashvilleHousing
-------------------------------------------------------------------------------------------
--Standardize Date Format

Alter table NashvilleHousing
Alter Column SaleDate Date

-- ATAU PAKE INI

Select SaleDate, CONVERT(Date, SaleDate)
from NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)
-------------------------------------------------------------------------------------------
-- Populate property Address Data

Select *
from NashvilleHousing
Where PropertyAddress IS NULL
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(A.PropertyAddress,b.PropertyAddress)
-- ISNULL digunakan untuk memunculkan nilai B.PropertyAddress pada A.PropertyAddress yang bernilai NULL
from NashvilleHousing A
Join NashvilleHousing B
	On a.ParcelID = b.ParcelID
	-- ON pada populate digunakan untuk melihat salah satu data yang sama dari dua faktor
	And a.UniqueID <> b.UniqueID
	-- And pada populate digunakan untuk memisah ada atau tiadanya dari setiap tabel
Where a.PropertyAddress is Null

Update A
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing A
Join NashvilleHousing B
	On a.ParcelID = b.ParcelID
	And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null






-------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address,
-- Mencari karakter sebelum Koma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , Len(PropertyAddress)) as State
-- Mencari karakter setelah Koma
From NashvilleHousing

-- Catatan Substring pertama di atas akan menyisakan , di akhir maka harus di TRIM(Trailing','From Kolom)
sELECT SplitAddress 
from NashvilleHousing
alter table NashvilleHousing
add SplitAddress Nvarchar(250)
	Update NashvilleHousing
	set SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress))
	Select TRIM(TRAILING','FROM SplitAddress)
	from NashvilleHousing
		Update NashvilleHousing
		set SplitAddress = TRIM(TRAILING','FROM SplitAddress)

alter table NashvilleHousing
add SplitCity Nvarchar(250)

Update NashvilleHousing
set SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , Len(PropertyAddress))

Select CHARINDEX('is', 'This is a String',4)

Select OwnerAddress
from NashvilleHousing

Select OwnerAddress
,PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From NashvilleHousing
-------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case	When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END
From NashvilleHousing

Alter table NashvilleHousing
Alter Column SoldAsVacant Varchar(50)

Select 
Case	When SoldAsVacant = NULL then 'Yes'
		When SoldAsVacant = 0 Then 'No'
		ELSE SoldAsVacant
end
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case	When SoldAsVacant = NULL then 'Yes'
		When SoldAsVacant = 0 Then 'No'
		ELSE SoldAsVacant
end

Select SoldAsVacant
from NashvilleHousing;



-------------------------------------------------------------------------------------------
-- Remove Duplicates
With Duplicate as
(
	Select *,
	ROW_NUMBER()Over(Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by uniqueID ) as Row_Num
	From NashvilleHousing
)
Select *
from Duplicate
Where Row_Num > 1

With Duplicate as
(
	Select *,
	ROW_NUMBER()Over(Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by uniqueID ) as Row_Num
	From NashvilleHousing
)
Delete
from Duplicate
Where Row_Num > 1

Select *
From NashvilleHousing

-------------------------------------------------------------------------------------------
-- Delete Unused Columns

alter table nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress