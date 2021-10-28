import os
from azureml.core import Workspace
from azureml.core.authentication import AzureCliAuthentication
import sys

workspace=sys.argv[1]
subscription_id=sys.argv[2]
resource_grp=sys.argv[3]

cli_auth = AzureCliAuthentication()
ws = Workspace(workspace_name = workspace,
               subscription_id = subscription_id,
               resource_group = resource_grp,
               auth=cli_auth)
#

print(ws.name, ws.resource_group, ws.location, ws.subscription_id, sep='\n')

datastore = ws.get_default_datastore()
datastore.upload_files(files = ['data/german_credit_data.csv'],
                       target_path = '/data/german_credit_data/file/',
                       overwrite = True,
                       show_progress = True)



from azureml.core import Dataset
dataset = Dataset.File.from_files((datastore, 'data/german_credit_data/file/german_credit_data.csv'))

dataset = dataset.register(workspace = ws,
                                 name = 'german_credit_file',
                                 description = 'german_credit_file',
                                 create_new_version = True)
