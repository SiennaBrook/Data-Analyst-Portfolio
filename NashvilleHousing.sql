--Cleaning Data in SQL
select *
from PortfolioProject.dbo.NashvilleHousing

--Standardization of Data
Alter table PortfolioProject.dbo.NashvilleHousing
ADD AlteredSalesDate date;

select AlteredSalesDate,SaleDate
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set AlteredSalesDate=convert(date,SaleDate)


--Populate Property Address Data
select a.ParcelId,a.PropertyAddress,b.ParcelId,b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
   on a.ParcelId=b.ParcelId
   and a.UniqueId<>b.UniqueId
where a.PropertyAddress is null

update a
set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
   on a.ParcelId=b.ParcelId
   and a.UniqueId<>b.UniqueId
where a.PropertyAddress is null

--breaking the address into 3 columns
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add splitAddress varchar(255)

update  PortfolioProject.dbo.NashvilleHousing
set splitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table PortfolioProject.dbo.NashvilleHousing
add splitCity varchar(255)

update  PortfolioProject.dbo.NashvilleHousing
set splitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress varchar(255)

update  PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(ownerAddress,',','.'),1)

Alter Table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity varchar(255)

update  PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(ownerAddress,',','.'),2)

Alter Table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState varchar(255)

update  PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState=PARSENAME(replace(ownerAddress,',','.'),3)

--change Y and N to yes and no 
select DISTINCT(SoldAsVacant),Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant

Select SoldAsVacant,
CASE
    when SoldAsVacant='Y' THEN 'yes'
	when SoldAsVacant='N' Then 'No'
	else SoldAsVacant
END
from PortfolioProject..NashvilleHousing

--removing duplicate rows
with RowNum as{
select *,
      ROW_NUMBER()over(
	  partition by ParcelID,
	  PropertyAddress,
	  SalesPrice,
	  LegalReference
	  order 
	  )
     


