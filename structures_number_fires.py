# Structures Destroyed & Number of Fires

# In[1]:
import pandas as pd

# In[2]:
fires = pd.read_csv('California_Fire_2013_2019.csv')
fires['Year'] = fires.apply(lambda row: str(row['Started'])[0:4], axis = 1)
major = fires[fires['MajorIncident'] == True]


# In[3]:
import plotly.graph_objects as go
from plotly.subplots import make_subplots

num_fires = fires.groupby(['Year'])['Name'].count()
structures_destroyed = fires.groupby(['Year'])['StructuresDestroyed'].sum()

# Create figure with secondary y-axis
fig = make_subplots(specs=[[{"secondary_y": True}]])

# Add traces
fig.add_trace(
    go.Scatter(x=num_fires.index, y=num_fires.values, name="Number of Wildfires"),
    secondary_y=False,
)

fig.add_trace(
    go.Scatter(x=structures_destroyed.index, y=structures_destroyed.values, name="Structures Destroyed"),
    secondary_y=True,
)

# Add figure title
fig.update_layout(
    title_text="2013-2019 Wildfire Statistics"
)

# Set x-axis title
fig.update_xaxes(title_text="Year")

# Set y-axes titles
fig.update_yaxes(title_text="Number of Wildfires", secondary_y=False)
fig.update_yaxes(title_text="Structures Destroyed", secondary_y=True)

fig.show()

