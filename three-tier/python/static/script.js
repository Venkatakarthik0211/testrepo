document.addEventListener('DOMContentLoaded', function() {
    loadTodos();

    const todoForm = document.getElementById('todo-form');
    todoForm.addEventListener('submit', function(event) {
        event.preventDefault();
        const todoTitle = document.getElementById('todo-title').value;
        addTodo(todoTitle);
        todoForm.reset();
    });
});

function loadTodos() {
    fetch('/api/todos')
        .then(response => response.json())
        .then(todos => {
            const todoList = document.getElementById('todo-list');
            todoList.innerHTML = '';
            todos.forEach(todo => {
                const li = document.createElement('li');
                li.innerHTML = `
                    <span>${todo.title}</span>
                    <button onclick="deleteTodo(${todo.id})">Delete</button>
                `;
                todoList.appendChild(li);
            });
        });
}

function addTodo(title) {
    fetch('/api/todos', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ title: title }),
    })
    .then(response => response.json())
    .then(newTodo => {
        const todoList = document.getElementById('todo-list');
        const li = document.createElement('li');
        li.innerHTML = `
            <span>${newTodo.title}</span>
            <button onclick="deleteTodo(${newTodo.id})">Delete</button>
        `;
        todoList.appendChild(li);
    });
}

function deleteTodo(todoId) {
    fetch(`/api/todos/${todoId}`, {
        method: 'DELETE',
    })
    .then(() => {
        const todoList = document.getElementById('todo-list');
        const todos = todoList.getElementsByTagName('li');
        for (let i = 0; i < todos.length; i++) {
            const span = todos[i].getElementsByTagName('span')[0];
            if (span.textContent === todoId.toString()) {
                todoList.removeChild(todos[i]);
                break;
            }
        }
    });
}
