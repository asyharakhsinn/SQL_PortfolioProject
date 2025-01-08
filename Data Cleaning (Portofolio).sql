/***

Portofolio Projects
"Data CLeansing""
Procedures
1. Remove Duplicates
2. Standardize the Data
3. Null Values or blank values
4. Remove Any Columns


***/

-- ---------------------------------------------------------------------------------------
/*** 

1. REMOVING DUPLICATE

***/
Select *
From layoffs;

--Search Duplicate With Equal values 
--With CTE
With Duplicate as
(
	Select *,
	ROW_NUMBER() Over(
	Partition By 
	company, location,
	industry, total_laid_off,
	percentage_laid_off, 'date', stage, country, funds_raised_millions order by company) as row_num
	From [Data Layoffs]..layoffs
)
Select *
From Duplicate
Where row_num > 1;

--Removing Duplicates
With Duplicate as
(
	Select *,
	ROW_NUMBER() Over(
	Partition By 
	company, location,
	industry, total_laid_off,
	percentage_laid_off, 'date', stage, country, funds_raised_millions order by company) as row_num
	From [Data Layoffs]..layoffs
)
Delete
From Duplicate
Where row_num > 1;

-- -------------------------------------------------------------------------------------
/*** 

2. Standardizing Data

***/

Select Distinct company,(TRIM(company)) AS A
From [Data Layoffs]..layoffs

Select DISTINCT industry
From [Data Layoffs]..layoffs
Order By 1;

--Checking if the industries is included in a category of industry
-- UPDATING
	--1. CRYPTO INDUSTRIES
Select *
From [Data Layoffs]..layoffs
WHere industry Like 'Crypto%';

	Update layoffs
	set industry = 'Crypto'
		Where industry Like 'Crypto%';

	--2. FINANCE
SELECT *
fROM layoffs
Where industry Like 'FIN';

	Update layoffs
	set industry = 'Finance'
		Where industry like 'FIN-%';


	--3. HR/HC
Select Distinct industry
From layoffs
Order BY 1
	Select *
	From layoffs
	WHere industry like 'HR' OR industry Like 'Recruiting'
	Order By 1
		Update layoffs
		set industry = 'HR'
			WHere industry Like 'Recruiting'

	--4. Country Misspelled
Select Distinct country
From layoffs
Order By 1

Select Distinct country
From layoffs
Where country like 'United States%'

	Update layoffs
	set country = 'United States'
		Where country like 'United States%'
	--OR (Does for removing anomaly characters for every values in the chosen column)
	Select Distinct Country, TRIM(Trailing'.'From Country)
	From layoffs
	order by 1

	--5 Formatting Date
Select distinct Date
from layoffs

-- In SSMS
Select Convert(date,date)
From layoffs
Select date, CONVERT(date,date)
From Layoffs

UPDATE layoffs
Set date = Convert(date,date)

-- Only WAY IN MySQL Workbence
Select STR_TO_DATE(DATE, '%m/%d/%Y')
From layoffs;
	Update layoffs
	Set `date` = STR_TO_DATE (`date`, '%m/%d/%Y');

Alter table layoffs
alter column `date` date ;

Select *
From layoffs

-- -------------------------------------------------------------------------------------
/*** 

3. Null Values and Blank Values

A. NULL values akan diabaikan dalam agg function (SUM, MIN, MAX, AVG)
B. NULL menandakan ketidaktahuan sedangkan 0 mewakili angka nol
C. 0 akan ikut ke dalam fungsi agregasi
D. Sebaiknya jika melihat NULL pada kolom type Float/INT sebaiknya didiamkan

***/
Select total_laid_off
From layoffs

Update layoffs
Set total_laid_off = NULL 
	Where total_laid_off = 0

Alter table layoffs
alter column total_laid_off float


	--POPULATING THE DATA
--Blank INDUSTRY
Select *
From layoffs
Where industry is null
or industry = ''

sELECT *
From layoffs
WHere company = 'Airbnb'

--POPULATE WITH SELF-JOIN
--

/***
Utamanya ada di klausa 'Where' dan 'And' 
buat membandingkan kemunculan values yang NULL/BLANK dari tabel joins
***/
Select T1.company, T1.industry, T2.company,t2.industry, ISNULL(T1.industry,T2.industry)
From layoffs T1
Join layoffs T2
	On  T1.company = T2.company
	And T1.location = T2.location
Where T1.industry is Null 
and T2.industry is not null
;

Update layoffs
SET industry = NULL
Where industry = ''

--SET UP POPULATE
Update T1
SET Industry = ISNULL(T1.industry,T2.industry)
From layoffs T1
Join layoffs T2
	On  T1.company = T2.company
	And T1.location = T2.location
Where T1.industry is Null 
and T2.industry is not null
;
--Checking if The NULL VALUES ARE DETERMINATED
--Results must be nothing
Select company from layoffs
Where industry IS NULL

-- --------------------------------------------------------
/*** 

4. REMOVE ANY COLUMNS and ROWS

***/
update layoffs
set percentage_laid_off = NULL
Where percentage_laid_off like 'NULL'
	alter table layoffs
	alter column percentage_laid_off float

Select *
From layoffs
WHere total_laid_off IS null
and percentage_laid_off is null

--Deleting
Delete
From layoffs
WHere total_laid_off IS null
and percentage_laid_off is null

-- DROP COLUMN
-- Use To remove existing irrelevant data 
Alter table layoffs
DROP COLUMN Row_Num;

Select * From
layoffs


-- ------------------------------------------------------------------------------------------------
