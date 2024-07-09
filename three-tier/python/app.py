from flask import Flask, jsonify, request, render_template
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://master:master1234@172.17.0.2/pdb'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Todo model
class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    completed = db.Column(db.Boolean, default=False)

    def serialize(self):
        return {
            'id': self.id,
            'title': self.title,
            'completed': self.completed
        }

# Routes
@app.route('/api/todos', methods=['GET'])
def get_todos():
    todos = Todo.query.all()
    return jsonify([todo.serialize() for todo in todos])

@app.route('/api/todos/<int:todo_id>', methods=['GET'])
def get_todo(todo_id):
    todo = Todo.query.get(todo_id)
    if todo:
        return jsonify(todo.serialize())
    return jsonify({'error': 'Todo not found'}), 404

@app.route('/api/todos', methods=['POST'])
def create_todo():
    data = request.get_json()
    new_todo = Todo(title=data['title'])
    db.session.add(new_todo)
    db.session.commit()
    return jsonify(new_todo.serialize()), 201

@app.route('/api/todos/<int:todo_id>', methods=['PUT'])
def update_todo(todo_id):
    todo = Todo.query.get(todo_id)
    if not todo:
        return jsonify({'error': 'Todo not found'}), 404
    data = request.get_json()
    todo.title = data.get('title', todo.title)
    todo.completed = data.get('completed', todo.completed)
    db.session.commit()
    return jsonify(todo.serialize())

@app.route('/api/todos/<int:todo_id>', methods=['DELETE'])
def delete_todo(todo_id):
    todo = Todo.query.get(todo_id)
    if not todo:
        return jsonify({'error': 'Todo not found'}), 404
    db.session.delete(todo)
    db.session.commit()
    return '', 204

# Serve the index.html file
@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    # Ensure application context is pushed before calling db.create_all()
    with app.app_context():
        db.create_all()
    
    # Run the Flask application
    app.run(debug=True)
