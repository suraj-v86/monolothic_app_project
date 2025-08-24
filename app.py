from flask import Flask, render_template, request, redirect, url_for
import sqlite3
import os

app = Flask(__name__)
DB_NAME = "tasks.db"

# Ensure database file path is absolute for systemd/Gunicorn
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), DB_NAME)

def init_db():
    """Initialize the SQLite database."""
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            done BOOLEAN NOT NULL DEFAULT 0
        )
        """)
        conn.commit()

# Initialize database when module is imported
init_db()

@app.route("/")
def index():
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT id, title, done FROM tasks")
        tasks = cursor.fetchall()
    return render_template("index.html", tasks=tasks)

@app.route("/add", methods=["POST"])
def add():
    title = request.form.get("title")
    if title:
        with sqlite3.connect(DB_PATH) as conn:
            cursor = conn.cursor()
            cursor.execute("INSERT INTO tasks (title, done) VALUES (?, ?)", (title, 0))
            conn.commit()
    return redirect(url_for("index"))

@app.route("/toggle/<int:task_id>")
def toggle(task_id):
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT done FROM tasks WHERE id=?", (task_id,))
        current_status = cursor.fetchone()[0]
        new_status = 0 if current_status else 1
        cursor.execute("UPDATE tasks SET done=? WHERE id=?", (new_status, task_id))
        conn.commit()
    return redirect(url_for("index"))

@app.route("/delete/<int:task_id>")
def delete(task_id):
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM tasks WHERE id=?", (task_id,))
        conn.commit()
    return redirect(url_for("index"))

# Do NOT use app.run() when using Gunicorn
# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=8000, debug=True)
