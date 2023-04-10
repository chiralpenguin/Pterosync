import sys
import shutil
import datetime as dt
import pathlib as path

input_format = '%d'
dt_format = '%Y-%m-%d_%H-%M-%S'

servers_path = sys.argv[1]
purge_days = int(sys.argv[2])
threshold_time = dt.datetime.now() - dt.timedelta(days=purge_days)

servers_dir = path.Path(servers_path)
for server_path in servers_dir.iterdir():
    backups = [f for f in server_path.glob('*') if f.is_dir()]
    print(f"Server: {server_path.name} contains {len(backups)} backups.", )

    for backup in backups:
        backup_time = dt.datetime.strptime(backup.name, dt_format)
        if backup_time < threshold_time:
            print(f"Deleting backup from: {backup_time}...")
            shutil.rmtree(backup)

    new_backups = [f for f in server_path.glob('*') if f.is_dir()]
    print(f"Server: {server_path.name} has {len(new_backups)} backups remaining.", )
