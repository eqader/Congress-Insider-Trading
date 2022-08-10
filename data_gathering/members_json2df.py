import json
import pandas as pd
import os

print(os.getcwd())
file_list = os.listdir('./members/')

def nested_json_convert(filepath, key_list):
	with open('./members/'+filepath, 'r') as f:
		data = json.loads(f.read())

	df = pd.json_normalize(data, record_path = key_list)

	return df
	
cat_df = pd.DataFrame()
for file in file_list:
	df = nested_json_convert(filepath = file, key_list = ['results', 'members'])
	cat_df = cat_df.append(df, ignore_index = True)

cat_df.to_csv('../analysis/members.csv')