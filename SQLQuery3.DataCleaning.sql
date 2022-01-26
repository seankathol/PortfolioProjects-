/* 

Cleaning Data in SQL Queries 

*/ 

Select *
	from [Portfolio Project].dbo.nashvillehousing 
	

-----------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format 


Select SaleDate, convert(date,SaleDate)
	from [Portfolio Project].dbo.NashvilleHousing

Alter table [Portfolio Project].dbo.NashvilleHousing 
	add saledate2 date;

Update [Portfolio Project].dbo.NashvilleHousing 
	set saledate2 = convert(date, SaleDate)



-----------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address 

Select *
	from [Portfolio Project].dbo.NashvilleHousing
	--where PropertyAddress is null
	order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
	from [Portfolio Project].dbo.NashvilleHousing a
	join [Portfolio Project].dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

Update a
	set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
	from [Portfolio Project].dbo.NashvilleHousing a
	join [Portfolio Project].dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]

-----------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
	from [Portfolio Project].dbo.NashvilleHousing
	--where PropertyAddress is null
	--order by ParcelID

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as StreetAddress
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , len(PropertyAddress)) as City
	from [Portfolio Project].dbo.NashvilleHousing

Alter table [Portfolio Project].dbo.NashvilleHousing 
	add StreetAddress nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing 
	set StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

Alter table [Portfolio Project].dbo.NashvilleHousing 
	add City nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing 
	set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , len(PropertyAddress))


-- Parsename vs. Substring 

Select 
	PARSENAME(replace(OwnerAddress, ',' , '.'), 3)
	, PARSENAME(replace(OwnerAddress, ',' , '.'), 2)
	,PARSENAME(replace(OwnerAddress, ',' , '.'), 1)
	from [Portfolio Project].dbo.NashvilleHousing

Alter table [Portfolio Project].dbo.NashvilleHousing 
	add OwnerStreet nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing 
	set OwnerStreet = PARSENAME(replace(OwnerAddress, ',' , '.'), 3)

Alter table [Portfolio Project].dbo.NashvilleHousing 
	add OwnerCity nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing 
	set OwnerCity = PARSENAME(replace(OwnerAddress, ',' , '.'), 2)

Alter table [Portfolio Project].dbo.NashvilleHousing 
	add OwnerState nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing 
	set OwnerState = PARSENAME(replace(OwnerAddress, ',' , '.'), 1)


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y & N to Yes & No in "Sold as Vacant" field 

Select Distinct(SoldAsVacant), count(SoldAsVacant)
	from [Portfolio Project].dbo.NashvilleHousing
	group by SoldAsVacant
	order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
	from [Portfolio Project].dbo.NashvilleHousing

Update [Portfolio Project].dbo.NashvilleHousing 
	set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

-----------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
With RowNumCTE as(
Select *
	, row_number() over (
	partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by ParcelID
				 ) rownum
	
	from [Portfolio Project].dbo.NashvilleHousing
)
Delete 
	from RowNumCTE
	where rownum > 1
	
 -- Double Check

With RowNumCTE as(
Select *
	, row_number() over (
	partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by ParcelID
				 ) rownum
	
	from [Portfolio Project].dbo.NashvilleHousing
)
Select * 
	from RowNumCTE
	where rownum > 1
	order by PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
	from [Portfolio Project].dbo.NashvilleHousing

Alter table [Portfolio Project].dbo.NashvilleHousing
	drop column SaleDate