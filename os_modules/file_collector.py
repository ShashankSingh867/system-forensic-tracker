import time, getpass
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from config import WATCH_FOLDER
from db import insert_file_event, get_or_create_user

CURRENT_USER_ID = get_or_create_user(getpass.getuser())

class ForensicFileHandler(FileSystemEventHandler):
    def _log(self, path, event_type):
        print(f"[FILE] {event_type.upper()} -> {path}")
        try: insert_file_event(pid=None, user_id=CURRENT_USER_ID, file_path=path, event_type=event_type)
        except Exception: pass
    def on_created(self, event): 
        if not event.is_directory: self._log(event.src_path, 'create')
    def on_modified(self, event): 
        if not event.is_directory: self._log(event.src_path, 'modify')
    def on_deleted(self, event): 
        if not event.is_directory: self._log(event.src_path, 'delete')

def start_file_collector():
    print(f"[+] Watching folder: {WATCH_FOLDER}")
    observer = Observer()
    observer.schedule(ForensicFileHandler(), WATCH_FOLDER, recursive=True)
    observer.start()
    try:
        while True: time.sleep(1)
    except KeyboardInterrupt: observer.stop()
    observer.join()

if __name__ == "__main__":
    start_file_collector()