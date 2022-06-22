-- Cleaning data in SQL queries

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

select SaleDate, Convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

-- Updating Date Columns

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate) 

-- Checking the updated Columns

select SaleDateConverted, Convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------

-- Populating Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

-- for removing similarity we are doing Self Joins

select a.ParcelID , a.PropertyAddress ,b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL will check for the 1st arguement passed as null if found null it will convert with whatever it s found in the 2nd arguement.
from PortfolioProject.dbo.NashvilleHousing a																		-- For this case it will convert a.propertyaddress null values to b.property address's values.
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b. [UniqueID ]
where a.PropertyAddress is null

-- for checking if isnull is functioning or not
Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a																		
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b. [UniqueID ]
where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------

-- Breaking adress into Individua Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


----------------
-- for viewing the updated or splitted columns , we can see them added at last of the columns. (i,e, the last two columns)

select *
from PortfolioProject.dbo.NashvilleHousing

----------------
-- Now for owner address

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

Alter Table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter Table NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------

--Changing Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant) , count (SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
-- Now for viewing the changes made upwards

Select Distinct(SoldAsVacant) , count (SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

------------------------------------------------------------------------------------------

-- Removing Duplicates

With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress


Delete
from RowNumCTE
where row_num > 1
--Order by PropertyAddress

--------------------------------------------------------------------------------------------------------------

-- Deleting unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate