select *
from nashvillehousing


-- 1) Standardize Date Format

select SaleDate
from nashvillehousing

select SaleDate, convert(date, SaleDate)
from nashvillehousing

update nashvillehousing
set SaleDate = convert(date, SaleDate)

select SaleDate
from nashvillehousing

-- SQL Server was not making the change, trying a different method

alter table nashvillehousing
add convertedsaledate Date

update nashvillehousing
set convertedsaledate = convert(date, SaleDate)

select convertedsaledate
from nashvillehousing


-- 2) Populate Property Address data
	-- There are pairs of parcelIDs - one with a PropertyAddress, one without (null). We want to fill the null value rows with the same PropertyAddress of the pair.

select *
from nashvillehousing
where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing as a
join nashvillehousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing as a
join nashvillehousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

select *
from nashvillehousing
where PropertyAddress is null


-- 3) Split Address Fields into Individual Columns (Address, City, State)
	
	-- PropertyAddress

select PropertyAddress
from nashvillehousing

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as propertyaddress
from nashvillehousing

select substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as propertycity
from nashvillehousing

alter table nashvillehousing
add propertyaddress1 nvarchar(255)

alter table nashvillehousing
add propertycity nvarchar(255)

update nashvillehousing
set propertyaddress1 = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

update nashvillehousing
set propertycity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select propertyaddress1, propertycity
from nashvillehousing

	-- OwnerAddress

select OwnerAddress
from nashvillehousing

select parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from nashvillehousing

alter table nashvillehousing
add owneraddress1 nvarchar(255)

alter table nashvillehousing
add ownercity nvarchar(255)

alter table nashvillehousing
add ownerstate nvarchar(255)

update nashvillehousing
set owneraddress1 = parsename(replace(OwnerAddress, ',', '.'), 3)

update nashvillehousing
set ownercity = parsename(replace(OwnerAddress, ',', '.'), 2)

update nashvillehousing
set ownerstate = parsename(replace(OwnerAddress, ',', '.'), 1)

select owneraddress1, ownercity, ownerstate
from nashvillehousing


-- 4) Change Y/N to Yes/No in 'Sold as Vacant' Field

select distinct(SoldAsVacant), count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from nashvillehousing

update nashvillehousing
set SoldAsVacant =
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end

select distinct(SoldAsVacant), count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant


-- 5) Remove Duplicates

select *
from nashvillehousing

select *,
row_number() over
(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	order by UniqueID
) row_num
from nashvillehousing

with rownumcte as(
select *,
row_number() over
(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	order by UniqueID
) row_num
from nashvillehousing
)

select *
from rownumcte
where row_num > 1
order by PropertyAddress

with rownumcte as(
select *,
row_number() over
(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	order by UniqueID
) row_num
from nashvillehousing
)

delete
from rownumcte
where row_num > 1


-- 6) Delete Unused Columns

select *
from nashvillehousing

alter table nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table nashvillehousing
drop column SaleDate

select *
from nashvillehousing