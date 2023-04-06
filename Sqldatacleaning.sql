select * from NashvilleHousing

--standardzie date format
------------------------------------------------------------------------------------------------------------------------------------------------------

update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

select saledateconverted
from NashvilleHousing

alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted =CONVERT(date,SaleDate)



--------------------------------------------------------------------------------------------------------------------------------------------------------
--populate property adress data 

select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select  a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from sqldatacleaning..NashvilleHousing a
join sqldatacleaning..NashvilleHousing b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from sqldatacleaning..NashvilleHousing a
join sqldatacleaning..NashvilleHousing b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

------------------------------------------------------------------------------------------------------------------------------------------------------
--breaking out adress into indivisual coloumn 
select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
from NashvilleHousing

alter table NashvilleHousing
add PropertysplitAddress nvarchar(255);

update NashvilleHousing
set PropertysplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add Propertysplitcity nvarchar(255);

update NashvilleHousing
set Propertysplitcity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from NashvilleHousing

select
PARSENAME(replace(ownername,',','.'),3)
,PARSENAME(replace(ownername,',','.'),2)
,PARSENAME(replace(ownername,',','.'),1)

from nashvillehousing

alter table NashvilleHousing
add ownersplitAddress  nvarchar(255);

update NashvilleHousing
set ownersplitAddress =PARSENAME(replace(ownername,',','.'),3)

alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity=PARSENAME(replace(ownername,',','.'),2)


alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate=PARSENAME(replace(ownername,',','.'),1)


-----------------------------------------------------------------------------------------------------------------
--convert all y and n to yes and no 
select distinct(soldasvacant),count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select soldasvacant
,case when soldasvacant='y' then 'Yes'
      when soldasvacant='n' then 'No'
	  else soldasvacant
	  end
from NashvilleHousing

update NashvilleHousing
set soldasvacant=case when soldasvacant='y' then 'Yes'
      when soldasvacant='n' then 'No'
	  else soldasvacant
	  end
--------------------------------------------------------------------------------------------------------------------------------------------------
--Remove duplicates 
with rownumcte as(
select *,
   row_number() over( partition by
                         parcelid,
						 propertyaddress,
						 saleprice,
						 saledate,
						 legalreference
						 order by
						 uniqueid
						   )row_num
from sqldatacleaning..NashvilleHousing
)
select * 
from rownumcte
where row_num>1
ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------------------------
--DELETE unused column 

alter table sqldatacleaning..NashvilleHousing
drop column saledate

select * from sqldatacleaning..NashvilleHousing