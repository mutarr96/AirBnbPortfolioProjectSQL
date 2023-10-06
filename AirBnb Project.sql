
select *
from Airbnb..Listings$

select distinct(count(id))
from Airbnb..Listings$

--Browsing for the property_type in the data
select distinct(count(property_type)) as CountOfPropertyType, property_type
from Airbnb..Listings$
group by property_type
order by property_type

--Updating the data to count 'Bed & Breakfast' and 'Bed and Breakfast' as the same
Update Airbnb.dbo.listings$
Set property_type = Case When property_type = 'Bed & Breakfast' then 'Bed and Breakfast'
						 Else property_type	
						 End

--Browsing for the nulls in property_type
Select property_type
, Case When summary like '%apartment%' then 'Apartment'
						 when summary like '%bed and breakfast%' then 'Bed and Breakfast'
						 when summary like '%boat%' then 'Boat'
						 when summary like '%bungalow%' then 'Bungalow'
						 when summary like '%cabin%' then 'Cabin'
						 when summary like '%champer/rv%' then 'Champer/RV'
						 when summary like '%chalet%' then 'Chalet'
						 when summary like '%condominium%' then 'Condominium'
						 when summary like '%dorm%' then 'Dorm'
						 when summary like '%house%' then 'House'
						 when summary like '%loft%' then 'Loft'
						 when summary like '%other%' then 'Other'
						 when summary like '%tent%' then 'Tent'
						 when summary like '%townhouse%' then 'Townhouse'
						 when summary like '%treehouse%' then 'Treehouse'
						 when summary like '%yurt%' then 'Yurt'
						 else property_type
						 end as PropertyType
From Airbnb..Listings$
where property_type is null

--Updating the null in property_type
Update Airbnb..Listings$
Set property_type = Case When summary like '%apartment%' then 'Apartment'
						 when summary like '%bed and breakfast%' then 'Bed and Breakfast'
						 when summary like '%boat%' then 'Boat'
						 when summary like '%bungalow%' then 'Bungalow'
						 when summary like '%cabin%' then 'Cabin'
						 when summary like '%champer/rv%' then 'Champer/RV'
						 when summary like '%chalet%' then 'Chalet'
						 when summary like '%condominium%' then 'Condominium'
						 when summary like '%dorm%' then 'Dorm'
						 when summary like '%house%' then 'House'
						 when summary like '%loft%' then 'Loft'
						 when summary like '%other%' then 'Other'
						 when summary like '%tent%' then 'Tent'
						 when summary like '%townhouse%' then 'Townhouse'
						 when summary like '%treehouse%' then 'Treehouse'
						 when summary like '%yurt%' then 'Yurt'
						 else property_type
						 end


--Count of beds 
select distinct(count(beds)) as CountOfBeds, beds
from Airbnb..Listings$
group by beds
order by beds

--Price Analysis by Beds
select beds, avg(price) as AvgPrice, min(price) as MinPrice, Max(price) as MaxPrice, Avg(cleaning_fee) as AvgCleaningFee
from Airbnb.dbo.Listings$
where cleaning_fee is not null
group by beds
order by beds

--Determing the count of properties by each zipcode
select zipcode, count(*) as CountOfListings
from Airbnb..Listings$
group by zipcode
order by zipcode

--Fixing the Nulls in zipcode
Update a
Set zipcode = ISNULL(a.zipcode, (Substring (a.street, CHARINDEX(',', a.street) +14, 5)))
-- +14 mean to start at the 14th position after the comma
from Airbnb.dbo.Listings$ a
join Airbnb.dbo.Listings$ b
	on a.id = b.id

--Price Analysis by Zipcode
select zipcode, avg(price) as AvgPrice, min(price) as MinPrice, Max(price) as MaxPrice, Avg(cleaning_fee) as AvgCleaningFee
from Airbnb.dbo.Listings$
where cleaning_fee is not null
group by zipcode
order by zipcode

--Price Analysis by Property Type
Select distinct (count(property_type)) as CountOfPropertyType, property_type, Avg(review_scores_rating) as AvgReview, avg(price) as AvgPrice 
,Avg (cleaning_fee) as AvgCleaningFee
from Airbnb.dbo.Listings$
where cleaning_fee is not null
group by property_type
order by property_type


--Showing which property is most frequent by zipcode
With RankedPropertyTypes As (
Select zipcode, property_type, ROW_NUMBER() Over (Partition by zipcode Order by COUNT(*) desc) as rank
From Airbnb..Listings$
Group by zipcode, property_type
)
Select zipcode, property_type
From RankedPropertyTypes
Where rank = 1

--Number of properties owned by individual hosts 
Select distinct host_name, host_total_listings_count
from Airbnb.dbo.Listings$
where host_total_listings_count is not null
order by host_name


--Replacing t and f with True and False and updating the data
Update Airbnb.dbo.Listings$
Set host_is_superhost = CASE When host_is_superhost = 't' then 'True'
		When host_is_superhost = 'f' then 'False'
		Else host_is_superhost
		End

--Superhost property performance
Select count(property_type) as propertycount, property_type, avg(price) as AvgPrice, avg(review_scores_rating) AvgReview
from Airbnb.dbo.Listings$
where host_is_superhost = 'True'
group by property_type


--Determining for every zipcode, what is the count of each property
Select zipcode, property_type, Count(*) as property_count
From Airbnb.dbo.Listings$
Group by zipcode, property_type
Order by zipcode, property_type

--Determing for every zipcode, what is the count of the property count and as a percentage of the property in each zipcode
--First Table
Drop table if exists #PropertyTypeCount
Create Table #PropertyTypeCount
(
zipcode int,
property_type nvarchar(50),
property_count int
)
Insert into #PropertyTypeCount
Select zipcode, property_type, count(*) as property_count
From Airbnb.dbo.Listings$
group by zipcode, property_type
--Second Table
Drop table if exists #TotalCountsByZipcode
Create Table #TotalCountsByZipcode
(
zipcode int,
total_count int
)
Insert into #TotalCountsByZipcode
Select zipcode, sum(property_count) as total_count
From #PropertyTypeCount
Group by zipcode
--Querying from both tables
select p.zipcode, p.property_type, p.property_count, CAST(p.property_count * 100.0 / t.total_count AS DECIMAL(10, 2)) AS percentage
--cast converts them to same data type and adding decimal (10,2) means 10 digits and 2 decimals places
From #PropertyTypeCount as p
Join #TotalCountsByZipcode as t
	on p.zipcode = t.zipcode
Order by p.zipcode, p.property_type



Select *
From #PropertyTypeCount

Select * 
From #TotalCountsByZipcode
