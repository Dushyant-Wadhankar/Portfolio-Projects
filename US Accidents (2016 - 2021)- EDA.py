#!/usr/bin/env python
# coding: utf-8

# # US Accidents (2016 - 2021)- Exploratory Analysis and Visualization
# 
# #### The following dataset contains Car Accident Data from the year 2016-2021, which covers 49 States of the USA (excluding New York State).
# #### The data set is sourced from Kaggle and has 2,845,352 Rows & 47 Columns (ID, City, Weather_Condition, Start_Time, Temperature, etc.)
# 
# #### An extensive analysis has been carried out on the dataset. A glimpse of the parameters that have been covered is mentioned below:
# - States and Cities with highest number of accidents.
# - Frequency of occurance of majority of accidents based on Time of the day, day of the week, month and year.
# - Weather & Other Conditions at the time of majority of the accidents. 
# 
# #### This analysis will be helpful to analyze current trend of accidents and prevent future accidents.

# 
# ## 1. Data Download
# ***

# In[3]:


pip install opendatasets --quiet


# In[1]:


import opendatasets as od

download_url = 'https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents/code?select=US_Accidents_Dec21_updated.csv'

od.download(download_url)


# ## 2. Data Preparation and Cleaning
# ***
# 
# #### - Load the file using Pandas.
# #### - Look at some info about the data and columns.
# #### - Fix any missing or incorrect values.
# ***

# ### Importing Libraries

# In[4]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import geopandas as gpd
import seaborn as sns

sns.set_style("darkgrid")


# In[2]:


data_file = 'us-accidents/US_Accidents_Dec21_updated.csv'


# In[5]:


df = pd.read_csv(data_file) #To read CSV file


# ### Information about the dataset.

# In[10]:


df.columns #Gives info about the columns.


# In[11]:


df.info # Gives overall info of dataset. 


# In[12]:


df.dtypes #Data type of attributes


# ### Finding Columns with null values. 

# In[121]:


missing_percentages = (df.isnull().sum().sort_values(ascending=False) / len(df))*100
missing_percentages[:20]


# #### The following columns have more than 1% of null values.
# 1. Number                   61.29%,
# 2. Precipitation(in)        19.31%,
# 3. Wind_Chill(F)            16.50%,
# 4. Wind_Speed(mph)           5.55%,
# 5. Wind_Direction            2.59%,
# 6. Humidity(%)               2.56%,
# 7. Weather_Condition         2.48%,
# 8. Visibility(mi)            2.47%,
# 9. Temperature(F)            2.43%,
# 10. Pressure(in)              2.08%,
# 11. Weather_Timestamp         1.78%.

# ### Plotting a graph of columns with missing values.

# In[122]:


plt.plot(missing_percentages[:5][missing_percentages != 0], color= 'black') #Plot graph of missing values


# # 3. Analysis
# ***
# 
# ### Columns that we will analyze:
# 1. City 
# 2. Start Time
# 3. Start Lat, Start Long
# 4. Temperature
# 5. Weather Condition
# 6. Crossings, Traffic Signal, Bumps
# 7. States with highest number of accidents
# 8. Timezone with maximum accidents
# 

# ***
# ## 3.1 City

# #### Information about City Column

# In[15]:


df.City # Info about City column.


# ###### The number of unique cities is 11682

# In[16]:


cities = df.City.unique()
len(cities) # No. of unique cities


# ##### Top 20 Cities in USA with highest number of accidents.

# In[124]:


cities_by_accident = df.City.value_counts()
print(cities_by_accident[:20])

# Top 20 cities with highest accidents.


# #### Values for New York City and New York State are missing in this dataset.

# In[18]:


"New York" in df.City # New York state is not there in this dataset


# In[19]:


"New York" in df.State # New York state is not there in this dataset


# #### Graph representing the top 20 cities with highest number of accidents in USA.

# In[127]:


cities_by_accident[:20].plot(kind='barh', color='red') # Top 20 Cities having max accidents.


# In[21]:


high_accident_cities = cities_by_accident[cities_by_accident >= 1000]
low_accident_cities = cities_by_accident[cities_by_accident < 1000]


# ##### Out of the total 11682 cities, 496 cities have greater than 1000 accidents.

# In[22]:


len(high_accident_cities) # No. of cities with >= 1000 accidents


# In[23]:


(len(high_accident_cities) / len(cities)) * 100 # Percentage of cities with >= 1000 accidents


# ##### According to the following histogram, majority of the cities have reported less than 10 accidents.

# In[66]:


sns.histplot(cities_by_accident, log_scale=True)


# ##### 4628 Cities have less than or equal to 10 accidents reported.

# In[28]:


cities_by_accident[cities_by_accident <= 10]


# ***
# ## 3.2 Start Time

# #### Convert the Start_Time column from 'string' to 'datetime'.

# In[87]:


df.Start_Time = pd.to_datetime(df.Start_Time) #Convert string to datetime


# In[88]:


df.Start_Time.dt.hour 


# ##### Majority of accidents happen between 1300 hrs & 1900 hrs followed by 0600 hrs & 1000 hrs.

# In[97]:


sns.histplot(df.Start_Time.dt.hour, bins=24, color= 'lightseagreen') # No. of accidents (hours of the day)


# ##### Majority of the accidents occur during the weekdays, with a significant drop during the weekends. 
# ##### (In the graph, Monday=0 & Sunday=6)

# In[101]:


sns.histplot(df.Start_Time.dt.dayofweek, bins=7, color= 'limegreen') # No. of accidents (Days of the week)


# ##### Majority of the accidents occur in the last quarter with maximum accidents being reported in the month of December>November>October>September.
# 
# ##### (In the graph, January = 1 & December = 12)

# In[104]:


sns.histplot(df.Start_Time.dt.month, bins=12, color= 'orangered') # No. of accidents (by Months)


# ##### On Weekends, majority of accidents occur between 1100 hrs & 2200 hrs

# In[111]:


sunday_start_time = df.Start_Time[df.Start_Time.dt.dayofweek == 6]
sns.histplot(sunday_start_time.dt.hour, bins=24, color='darkslategrey')

# No. of accidents (on Sundays)


# #### Compared to previous year, the year 2020-2021 had a significant increases in the number of accidents.

# In[117]:


sns.histplot(df.Start_Time.dt.year, bins= 5, color = 'red')


# ***
# ## 3.3 Start Lattitude & Longitude

# #### Information about Start Lattitude and Start Longitude columns.

# In[35]:


df.Start_Lat #info about column


# In[36]:


df.Start_Lng #info about column


# #### Scatter Plot of all the accidents based on the starting coordinates.

# In[67]:


sns.scatterplot(x=df.Start_Lng, y=df.Start_Lat, size= 0.0001)


# #### Installing and loading the 'Folium' library to create a heatmap.

# In[38]:


get_ipython().system('pip install folium --quiet')


# In[39]:


import folium
from folium.plugins import HeatMap


# #### Create a dictionary of Start_Lat & Start_Lng by using 'zip function'.

# In[40]:


list(zip(list(df.Start_Lat), list(df.Start_Lng)))[:10] # Create list of lattitude and longitude.


# #### Creating a heatmap using a sample dataset of 10% of the total 2.8 million records.

# In[41]:


sample_df = df.sample(int(0.01*len(df)))
lat_long = list(zip(list(sample_df.Start_Lat), list(sample_df.Start_Lng)))

# Using a sample dataset of 10% of the total 2.8 million records.


# In[42]:


map = folium.Map()
HeatMap(lat_long).add_to(map)
map


# ***
# ## 3.4 Temperature

# ### No. of Accidents at specific temperature (Fahrenheit)

# In[6]:


df['Temperature(F)'].value_counts()


# #### As per the plotted graph, a strong correltion between the number of accidents and Temperature cannot be made 

# In[96]:


sns.displot(df['Temperature(F)'], color= 'darkblue')


# ***
# ## 3.5 Weather Condition

# #### There are 128 unique weather conditions mentioned in the dataset

# In[19]:


len(df.Weather_Condition.unique())


# In[52]:


df_weather = df.Weather_Condition.value_counts()[:20] #Top 20 weather conditions with maximum accidents
df_weather


# #### From the graph, most of the accidents happened in Fair weather condition, indicating that weather condition does not affect number of accidents directly.

# In[129]:


df_weather.plot(kind= 'barh', color= 'teal')


# ***
# ## 3.6 Crossings, Traffic Signal, Bumps

# ##### 2,00,212 accidents happened near Crossings.

# In[38]:


df['Crossing'].value_counts().plot(kind= 'pie')


# In[71]:


df['Crossing'].value_counts() #True indicated accidents that happended near Crossings.


# ##### 2,65,263 accidents happened near Traffic Signal

# In[34]:


df['Traffic_Signal'].value_counts().plot(kind='pie')


# ##### 1,021 accidents happened near Bumps

# In[72]:


df['Traffic_Signal'].value_counts() #True indicated accidents that happended near Traffic Signals.


# In[46]:


df['Bump'].value_counts().plot(kind= 'pie')


# In[82]:


df['Bump'].value_counts() #True indicated accidents that happended near Bumps.


# ---
# ## 3.7 States with Highest Number of Accidents

# In[84]:


df_state = df.State.value_counts()[:10]
df_state #Top 10 States with maximum number of


# #### California was the state with highest number of accidents.

# In[81]:


df_state.plot(kind= 'barh', color= 'red')


# #### Majority of the accidents happened in the Eastern Timezone

# In[63]:


df.Timezone.value_counts().plot(kind='barh', color = 'darkgreen')


# ***
# ## Summary and Conclusion
# 
# - Miami City has the highest number of accidents, followed by Los Angeles, Orlando, Dallas, Houston and Charlotte.
# - California State has the maximum number of accidents followed by Florida, Texas,  Oregon and Virginia.
# - Out of the total 11682 cities, 496 cities have greater than 1000 accidents which amounts for 4.24% of the total accidents. Whereas majority of the cities has less than 10 accidents reported.
# - During weekdays, majority accidents occured between 1 pm - 7 pm followed 6 am - 10 am. During weekends there is a significant drop in the number of accidents.
# - Majority of the accidents occured during winters wherein the months of November and December accounted for most of the accidents followed by October and September.
# - An exponential rise in accidents can be seen in the year 2020-2021 compared to the previous years.
# - Coastal Regions, especially the Eastern Coast reported maximum number of accidents.
# - Temperature and Weather Conditions have minimal relation with the majority number of accidents occured.
# - Almost half a million accidents (466496, to be precise), has occured due to poor traffic management (at traffic signals, crossings and bumps)
# ***
# ---

# ## Future Scope
# - Per-Capita accident figures can be analyzed if the population data is sourced from authentic sources.
# - An exponential rise in accidents was seen in the year 2020-2021, further analysis using external sources can be done to figure out the reason.
# - Predictive analysis can be done which will help in devising ways to prevent further accidents.

# ## Acknowledgements 
# 1. Moosavi, Sobhan, Mohammad Hossein Samavatian, Srinivasan Parthasarathy, and Rajiv Ramnath. “A Countrywide Traffic Accident Dataset.”, 2019.
# 2. Moosavi, Sobhan, Mohammad Hossein Samavatian, Srinivasan Parthasarathy, Radu Teodorescu, and Rajiv Ramnath. "Accident Risk Prediction based on Heterogeneous Sparse Data: New Dataset and Insights." In proceedings of the 27th ACM SIGSPATIAL International Conference on Advances in Geographic Information Systems, ACM, 2019.
# 3.  Jovian.ai
