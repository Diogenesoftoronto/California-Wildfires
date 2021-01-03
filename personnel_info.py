# Personnel Information

# In[1]:
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd

# In[2]:
acres = pd.read_csv('person.csv')

# In[3]:
acres.head()


# In[4]:
import plotly.express as px
fig = px.scatter(acres, x="personnel_per_acre", y="population", hover_data=['counties'])
fig.update_layout(title_text='Personnel per Acre vs Population of county')
fig.update_layout(xaxis_title= 'Personnel per Acre', yaxis_title= 'County Population')
fig.show()

