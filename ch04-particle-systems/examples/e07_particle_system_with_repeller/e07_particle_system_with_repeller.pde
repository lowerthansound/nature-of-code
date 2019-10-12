import java.util.Iterator;

ParticleSystem ps;
Gravity gravity;
Repeller repeller;

void setup() {
  size(200,200);
  ps = new ParticleSystem(width/2,50);
  gravity = new Gravity(0.05);
  repeller = new Repeller(new PVector(width/2-15,height/2-15),70);
}

void draw() {
  background(255);
  
  repeller.display();
  
  ForceGenerator[] fGenerators = {gravity,repeller};
  ps.run(fGenerators);
}

interface ForceGenerator {
  PVector forceOn(Particle particle);
}

class Gravity implements ForceGenerator {
  
  float G;
  
  Gravity(float G_) {
    G = G_;
  }
  
  PVector forceOn(Particle particle) {
    return new PVector(0,G);
  }
}

class Repeller implements ForceGenerator {
  
  PVector location;
  float G;
  
  Repeller(PVector location_, float G_) {
    location = location_.copy();
    G = G_;
  }
  
  PVector forceOn(Particle particle) {
    PVector displacement = PVector.sub(particle.location,location);
    float distance = displacement.mag();
    distance = constrain(distance,25,200);
    
    PVector result = displacement.copy();
    result.setMag(G/(distance*distance));
    return result;
  }
  
  void display() {
    stroke(0);
    fill(175);
    ellipse(location.x,location.y,45,45);
  }
}

class ParticleSystem {
  
  ArrayList<Particle> particles;
  
  PVector location;
  
  ParticleSystem(float x, float y) {
    particles = new ArrayList<Particle>();
    location = new PVector(x,y);
  }
  
  void run(ForceGenerator[] fGenerators) {
    _addParticle();
    _updateParticles(fGenerators);
  }
  
  void _addParticle() {
    particles.add(new Particle(location));
  }
  
  void _updateParticles(ForceGenerator[] fGenerators) {
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      p.display();
      p.update(fGenerators);
      if (p.isDead())
        it.remove();
    }
  }
}

class Particle {
  
  PVector location;
  PVector velocity = new PVector(random(-1,1),random(-2,-0.5));
  
  float lifespan = 255;
  
  Particle(PVector location_) {
    location = location_.copy();
  }
  
  void display() {
    stroke(0,lifespan);
    fill(175,lifespan);
    ellipse(location.x,location.y,16,16);
  }
  
  void update(ForceGenerator[] fGenerators) {
    PVector acceleration = new PVector(0,0);
    for (ForceGenerator fgen: fGenerators)
      acceleration.add(fgen.forceOn(this)); // assume mass = 1
    
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 2;
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}
