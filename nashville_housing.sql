USE nashville_housing

SELECT * 
  FROM nashville_housing 

--Adjust SaleDate Format
SELECT CAST(SaleDate AS DATE)
  FROM nashville_housing

ALTER TABLE nashville_housing 
  ADD sale_date_converted DATE

UPDATE nashville_housing
   SET sale_date_converted = CAST(SaleDate AS DATE)

--Populate Null Values in PropertyAddress
SELECT parcelid,propertyaddress 
  FROM nashville_housing
 WHERE propertyaddress IS NULL
 ORDER BY 1

SELECT n1.parcelid , n1.propertyaddress , n2.parcelid , n2.propertyaddress , 
       ISNULL(n1.propertyaddress, n2.PropertyAddress) property_address_converted 
  FROM nashville_housing n1
  JOIN nashville_housing n2 
    ON n1.ParcelID = n2.ParcelID AND n1.[UniqueID ] != n2.[UniqueID ]
 WHERE n1.PropertyAddress IS NULL

UPDATE n1
   SET n1.propertyaddress = ISNULL(n1.propertyaddress,n2.propertyaddress) 
  FROM nashville_housing n1
  JOIN nashville_housing n2
    ON n1.ParcelID = n2.ParcelID AND n1.[UniqueID ] != n2.[UniqueID ] 
 WHERE n1.PropertyAddress IS NULL


--Split property address to (address,city,state)
SELECT PropertyAddress,SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) address , 
	   SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) city
  FROM nashville_housing

ALTER TABLE nashville_housing
  ADD property_split_address VARCHAR(255)

UPDATE nashville_housing
   SET property_split_address = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) 

ALTER TABLE nashville_housing 
  ADD property_split_city VARCHAR(255)

UPDATE nashville_housing 
   SET property_split_city = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

--Split OwnerAddress Into address , city , state 

SELECT owneraddress, PARSENAME(REPLACE(owneraddress,',','.'),3) address,
	   PARSENAME(REPLACE(owneraddress,',','.'),2) city,
	   PARSENAME(REPLACE(owneraddress,',','.'),1) state
  FROM nashville_housing

ALTER TABLE nashville_housing 
  ADD owner_split_address VARCHAR(255)
  
UPDATE nashville_housing
   SET owner_split_address = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE nashville_housing 
  ADD owner_split_city VARCHAR(255)

UPDATE nashville_housing 
   SET owner_split_city = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE nashville_housing 
  ADD owner_split_state VARCHAR(255)

UPDATE nashville_housing 
   SET owner_split_state = PARSENAME(REPLACE(owneraddress,',','.'),1)

--REPLACE Y AND N to YES AND N IN SoldAsVacant
SELECT DISTINCT(soldasvacant)
  FROM nashville_housing

SELECT soldasvacant ,
	   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	   END 
  FROM nashville_housing

UPDATE nashville_housing
   SET SoldAsVacant =  
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	    END 

--Removing Duplicates
WITH cte_1 AS
(
SELECT * ,
	   ROW_NUMBER() OVER (PARTITION BY parcelid,propertyaddress,saleprice,sale_date_converted,legalreference ORDER BY uniqueid) row_num
  FROM nashville_housing
)

SELECT row_num
  FROM cte_1
 WHERE row_num > 1

  DELETE 
   FROM cte_1
  WHERE row_num > 1

--CREATE VIEW   SELECT * FROM nashville_housing 
DROP VIEW view_1 

CREATE VIEW view_1 AS 
SELECT uniqueid , ParcelID , sale_date_converted,SalePrice ,property_split_address,property_split_city, owner_split_address,
       owner_split_city,owner_split_state
  FROM nashville_housing






