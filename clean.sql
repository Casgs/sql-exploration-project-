--cleaning data

select * from [portfolio project 2].dbo.clean

--saledate

select saledate,convert(date,saledate) from [portfolio project 2].dbo.clean
--cast(saledate as date)

update [portfolio project 2].dbo.clean
set SaleDate = convert(date,saledate)

alter table clean
add saledate2 date

update clean
set saledate2 = convert(date,saledate)

--address data
--adding address to null where the parcel is same 


select * from clean
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from 
clean a 
join clean b
on a.ParcelID = b.ParcelID
where a.[UniqueID ] <> b.[UniqueID ]
and a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from clean a 
join clean b
on a.ParcelID = b.ParcelID
where a.[UniqueID ] <> b.[UniqueID ]
and a.PropertyAddress is null

--address,city,state


--select PropertyAddress,COUNT(PropertyAddress) from clean
--group by PropertyAddress

select PropertyAddress from clean

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address  -- the name is given till the , and also to remove it -1 is used
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as address -- len is used for the prop address

From clean

--add into table

ALTER TABLE clean
Add PropertySplitAddress Nvarchar(255);

Update clean
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE clean
Add PropertySplitCity Nvarchar(255);

Update clean
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--owner address

Select OwnerAddress
From clean


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From clean


ALTER TABLE clean
Add OwnerSplitAddress Nvarchar(255);

Update clean
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE clean
Add OwnerSplitCity Nvarchar(255);

Update clean
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


alter table clean
add ownersplitstate nvarchar(225);

Update clean
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--sold vacant y,n to yes,no

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From clean
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE 
When SoldAsVacant = 'y' then 'Yes'
	   When SoldAsVacant = 'n' then 'No'
	   ELSE SoldAsVacant
	   END
From clean


Update clean
SET SoldAsVacant = 
CASE 
       When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--remove dulpicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From clean 
)

Select * -- delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From clean

--delete cloumn

ALTER TABLE clean
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate