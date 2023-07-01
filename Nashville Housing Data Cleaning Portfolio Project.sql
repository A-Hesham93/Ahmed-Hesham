/*

    cleaning data in sql queries

*/



select *
from [Portfolio Project]..[Nashville Housing]
--------------------------------------------------------------------------------------



--- standarize date format
select saledateconverted, convert(date, saledate)
from [Portfolio Project]..[Nashville Housing]

alter table [Portfolio Project]..[Nashville Housing]
add saledateconverted date;

update [Portfolio Project]..[Nashville Housing]
set saledateconverted = convert(date, saledate)
------------------------------------------------------------------------------------------------



-- populate property address data
select *
from [Portfolio Project]..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID




select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..[Nashville Housing] a
join [Portfolio Project]..[Nashville Housing] b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..[Nashville Housing] a
join [Portfolio Project]..[Nashville Housing] b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------




-- breaking out address into individual columns (address, city, state)

select 
substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as address
, substring(propertyaddress, charindex(',',propertyaddress)+ 1, len(propertyaddress)) as city
from [Portfolio Project]..[Nashville Housing]

alter table [Portfolio Project]..[Nashville Housing]
add propertysplitaddress nvarchar(255);

update [Portfolio Project]..[Nashville Housing]
set propertysplitaddress = substring(propertyaddress, 1, charindex(',', propertyaddress)-1)

alter table [Portfolio Project]..[Nashville Housing]
add propertysplitcity nvarchar(255);

update [Portfolio Project]..[Nashville Housing]
set propertysplitcity = substring(propertyaddress, charindex(',',propertyaddress)+ 1, len(propertyaddress))


select *
from [Portfolio Project]..[Nashville Housing]




select OwnerAddress
from [Portfolio Project]..[Nashville Housing]


select
parsename(replace(OwnerAddress, ',' , '.'), 3) 
,parsename(replace(OwnerAddress, ',' , '.'), 2) 
,parsename(replace(OwnerAddress, ',' , '.'), 1) 
from [Portfolio Project]..[Nashville Housing]


alter table [Portfolio Project]..[Nashville Housing]
add OwnersplitAddress nvarchar(255);

update [Portfolio Project]..[Nashville Housing]
set OwnersplitAddress = parsename(replace(OwnerAddress, ',' , '.'), 3)

alter table [Portfolio Project]..[Nashville Housing]
add Ownersplitcity nvarchar(255);

update [Portfolio Project]..[Nashville Housing]
set Ownersplitcity = parsename(replace(OwnerAddress, ',' , '.'), 2)

alter table [Portfolio Project]..[Nashville Housing]
add Ownersplitstate nvarchar(255);

update [Portfolio Project]..[Nashville Housing]
set Ownersplitstate = parsename(replace(OwnerAddress, ',' , '.'), 1)

select *
from [Portfolio Project]..[Nashville Housing]
---------------------------------------------------------------------------------------------------------




-- change Y and N to Yes and No in 'sold as vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Portfolio Project]..[Nashville Housing]
group by SoldAsVacant
order by 2



select SoldAsVacant
,    case when SoldAsVacant = 'Y' then 'Yes'
          when SoldAsVacant = 'N' then 'No'
		  else SoldAsVacant
		  END
from [Portfolio Project]..[Nashville Housing]

update [Portfolio Project]..[Nashville Housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
          when SoldAsVacant = 'N' then 'No'
		  else SoldAsVacant
		  END
-----------------------------------------------------------------------------------------------




-- Remove Duplicates


with rownumCTE as(
select *,
        ROW_NUMBER() over(
		partition by parcelID,
		              propertyaddress,
					  saleprice,
					  saledate,
					  legalreference
					  order by uniqueid
					  ) row_num

from [Portfolio Project]..[Nashville Housing]
)

select *
from rownumCTE
where row_num > 1





with rownumCTE as(
select *,
        ROW_NUMBER() over(
		partition by parcelID,
		              propertyaddress,
					  saleprice,
					  saledate,
					  legalreference
					  order by uniqueid
					  ) row_num

from [Portfolio Project]..[Nashville Housing]
)

delete 
from rownumCTE
where row_num > 1
--------------------------------------------------------------------------------------------------------



-- Delete unused columns


alter table [Portfolio Project]..[Nashville Housing]
drop column owneraddress, taxdistrict, propertyaddress, saledate