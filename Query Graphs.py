
# Investigative Query Visualizations

# In[1]:
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd

# In[2]:
# Time Series Analysis: Month,Year vs Avg AQI & Acres Burned

year_month = pd.read_csv('year_month.csv')

# In[3]:
def str_date(year, month):
    
    month = str(int(month))
    if len(month) == 1:
        month = '0'+ month
    return f'{str(int(year))}-{month}-01'


# In[4]:
year_month['date'] = year_month.apply(lambda row: str_date(row['year(date)'], row['month(date)']) , axis=1)


# In[5]:
year_month.head(2)

# In[6]:
# Create traces
fig = go.Figure()
fig.add_trace(go.Scatter(x=year_month['date'], y=year_month['avg(aqi)'],
                    mode='lines', marker_color='#2adea5',
                    name='Monthly Average AQI'))

fig.update_layout(title= 'Monthly Average AQI from 2013-2019',
                  xaxis_title='Year',
                  yaxis_title='AQI')
fig.show()

# In[7]:
fig = go.Figure()
fig.add_trace(go.Scatter(x=year_month['date'], y=year_month['acres_burned'],
                    mode='lines+markers', marker_color='#e8666d',
                    name='Monthly Acres Burned'))

fig.update_layout(title= 'Acres Burned per Month from 2013-2019',
                  xaxis_title='Year',
                  yaxis_title='Acres Burned')
fig.show()


# ### Scatterplot #1 : Percent of County Burned vs AQI Level

# In[8]:
pct_aqi = pd.read_csv('percent_vs_aqi.csv')


# In[9]:
pct_aqi['percent'] = pct_aqi.apply(lambda row: row['percent'] * 100, axis=1)


# In[10]:
pct_aqi.head(2)


# In[11]:
fig = px.scatter(pct_aqi, x="percent", y="avg(aqi)", hover_name='county_name', trendline="ols",
                 color_discrete_sequence = ['#e89835'],
                 labels = {'percent' : 'Percentage of the County that has Burned',
                           'avg(aqi)' : 'Averge AQI'},
                title = 'Percentage of County that has Burned vs Average AQI Level')
fig.show()




# In[12]:
# Scatterplot #2: Percent of County Burned vs Precipitation

acres_prcp = pd.read_csv('acrespcrp.csv')

# In[13]:
acres_prcp.head()


# In[14]:
acres_prcp['percent'] = acres_prcp.apply(lambda row: row['burned'] * 100, axis=1)


# In[15]:
acres_prcp.head(2)


# In[16]:
fig = px.scatter(acres_prcp, x="percent", y="sum(prcp)", hover_name='county',
                 color_discrete_sequence = ['#3461eb'],
                 labels = {'percent' : 'Cummulative Percentage of County that has Burned',
                           'sum(prcp)' : 'Total Precipitation'},
                title = 'Percentage of County that has Burned vs Total Precipitation')
fig.show()

# In[17]:
# Scatterplot #3: Acres Burned, AQI, County Population
burned = pd.read_csv('burnaqi.csv')

# In[18]:
burned.head()

# In[19]:
fig = px.scatter(burned, x="acres", y="aqi", hover_name='counties', trendline="ols",
                 size = 'population', color_discrete_sequence = ['#e33c17'], size_max = 50,
                 labels = {'acres' : 'Total Number of Acres Burned',
                           'aqi' : 'Averge AQI'},
                title = 'Number of Acres Burned vs Avg AQI Level by County')
fig.show()






