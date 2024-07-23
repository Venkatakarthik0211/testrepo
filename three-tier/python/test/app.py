from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('SQLALCHEMY_DATABASE_URI')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = 'mysecretkey'

db = SQLAlchemy(app)

class Planet(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    distance = db.Column(db.Integer, nullable=False)
    radius = db.Column(db.Integer, nullable=False)
    mass = db.Column(db.Integer, nullable=False)

    def __init__(self, name, distance, radius, mass):
        self.name = name
        self.distance = distance
        self.radius = radius
        self.mass = mass

# Route to handle adding a new planet
@app.route("/add", methods=["POST"])
def add_planet():
    if request.method == "POST":
        name = request.form['name']
        distance = int(request.form['distance'])
        radius = int(request.form['radius'])
        mass = int(request.form['mass'])

        new_planet = Planet(name=name, distance=distance, radius=radius, mass=mass)
        db.session.add(new_planet)
        db.session.commit()
        flash('Planet added successfully')
    return redirect(url_for('index'))

# Route to handle editing a planet
@app.route("/edit/<int:planet_id>", methods=["GET", "POST"])
def edit_planet(planet_id):
    planet = Planet.query.get_or_404(planet_id)
    
    if request.method == "POST":
        planet.name = request.form['name']
        planet.distance = request.form['distance']
        planet.radius = request.form['radius']
        planet.mass = request.form['mass']
        db.session.commit()
        flash('Planet updated successfully')
        return redirect(url_for('index'))
    
    return render_template('edit.html', planet=planet)

# Route to handle deleting a planet
@app.route("/delete/<int:planet_id>", methods=["POST"])
def delete_planet(planet_id):
    planet = Planet.query.get_or_404(planet_id)
    db.session.delete(planet)
    db.session.commit()
    flash('Planet deleted successfully')
    return redirect(url_for('index'))

# Route to display all planets
@app.route("/")
def index():
    planets = Planet.query.all()
    return render_template('index.html', planets=planets)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
