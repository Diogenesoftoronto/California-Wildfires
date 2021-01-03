# Acres Burned per County

# In[1]:
import pandas as pd
import plotly.graph_objects as go

# In[2]:
counties = pd.read_csv('counties_3.csv')

# In[3]:
query = pd.read_csv('worst_place_to_live.csv')


# In[4]:
counties.head()


# In[5]:
query = query.rename(columns={'county':'County'})


# In[6]:
query.head()


# In[7]:
query_all = pd.merge(query, counties, on='County')


# In[8]:
query_all.head()


# In[9]:
def cal_fips(fip):
    CA_CODE = '06'
    zeros = '0'* (3 - len(fip))    
    return CA_CODE + zeros + fip  


# In[10]:
query_all['ca_fips'] = query_all.apply(lambda row: cal_fips(str(row['FIPS code'])), axis = 1)


# In[11]:
from urllib.request import urlopen
import json
with urlopen('https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json') as response:
    counties = json.load(response)


# In[12]:
import plotly.express as px
fig = px.choropleth_mapbox(query_all, geojson=counties, locations='ca_fips', color='sum(acresburned)',
                           color_continuous_scale="Plasma",
                           mapbox_style="open-street-map",
                           zoom=3, center = {"lat": 37.0902, "lon": -125.7129},
                           opacity=0.5,
                           labels={'sum(acresburned)':'Total Acres Burnt'}
                          )
fig.update_layout(margin={"r":0,"t":0,"l":0,"b":0})
fig.show()





