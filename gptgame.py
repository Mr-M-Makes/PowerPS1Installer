import pygame
import sys
import random
import math

def check_collision(rect1, rect2):
    return (rect1.x < rect2.x + rect2.size and rect1.x + rect1.size > rect2.x and
            rect1.y < rect2.y + rect2.size and rect1.y + rect1.size > rect2.y)

class Character:
    def __init__(self, x, y, size, color):
        # ... (rest of the code stays the same)
          # Initialize angle to 0
        self.x = x
        self.y = y
        self.size = size
        self.color = color
        self.angle = 0
        self.bullets = [] 

    def rotate(self, delta_angle):
        self.angle += delta_angle
        self.angle %= 360  # Keep angle between 0 and 360

    def move(self, dx, dy):
        self.x += dx
        self.y += dy

    def boundary_check(self, screen_width, screen_height):
        self.x = max(0, min(screen_width - self.size, self.x))
        self.y = max(0, min(screen_height - self.size, self.y))

    def shoot(self):
        half_size = self.size // 2
        bullet_x = self.x + half_size + half_size * math.sin(math.radians(self.angle))
        bullet_y = self.y + half_size - half_size * math.cos(math.radians(self.angle))
        
        new_bullet = Bullet(bullet_x, bullet_y, 5, (255, 0, 0), 5, self.angle)
        self.bullets.append(new_bullet)

    def draw(self, window):
        half_size = self.size // 2

        # Define the original points of the triangle (unrotated)
        points = [(self.x + half_size, self.y), (self.x, self.y + self.size), (self.x + self.size, self.y + self.size)]

        # Compute the rotated points
        rotated_points = []

        for px, py in points:
            dx = px - self.x - half_size
            dy = py - self.y - half_size

            new_dx = dx * math.cos(math.radians(self.angle)) - dy * math.sin(math.radians(self.angle))
            new_dy = dx * math.sin(math.radians(self.angle)) + dy * math.cos(math.radians(self.angle))

            rotated_x = self.x + half_size + new_dx
            rotated_y = self.y + half_size + new_dy

            rotated_points.append((rotated_x, rotated_y))

        pygame.draw.polygon(window, self.color, rotated_points)


class Bullet:
    def __init__(self, x, y, size, color, speed, angle):
        self.x = x
        self.y = y
        self.size = size
        self.color = color
        self.speed = speed
        self.angle = math.radians(angle)  # Convert to radians

    def update(self):
        self.x += self.speed * math.sin(self.angle)
        self.y -= self.speed * math.cos(self.angle)

    def draw(self, window):
        pygame.draw.line(window, self.color, 
                         (self.x, self.y), 
                         (self.x + self.size * math.sin(self.angle), self.y - self.size * math.cos(self.angle)), 
                         2)

class Enemy(Character):
    def __init__(self, x, y, size, color, speed):
        super().__init__(x, y, size, color)
        self.speed = speed

    def update(self):
        self.x -= self.speed

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH, SCREEN_HEIGHT = 800, 600
RED = (255, 0, 0)
GREEN = (0, 255, 0)
WHITE = (255, 255, 255)

# Set up the display
window = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption('Pygame with Shooting Triangle')

# Create a clock object to control the frame rate
clock = pygame.time.Clock()

# Initialize lives and points
lives = 3
points = 0
last_life_points = 0

# Create a Character instance
player = Character(50, 50, 50, RED)

# Create a list to hold Enemy instances
enemies = []

# Main event loop
while True:
    

    # Spawn a new enemy
    if random.randint(0, 30) == 0:
        new_enemy = Enemy(SCREEN_WIDTH, random.randint(0, SCREEN_HEIGHT - 50), 50, GREEN, 5)
        enemies.append(new_enemy)

    # Handle events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                player.shoot()
            if event.key == pygame.K_b:
                player.rotate(5)  # Rotate clockwise by 5 degrees
            if event.key == pygame.K_v:
                player.rotate(-5)

    # Get keys
    keys = pygame.key.get_pressed()

    if keys[pygame.K_LEFT]:
        player.move(-5, 0)
    if keys[pygame.K_RIGHT]:
        player.move(5, 0)
    if keys[pygame.K_UP]:
        player.move(0, -5)
    if keys[pygame.K_DOWN]:
        player.move(0, 5)

    # Boundary check

    # Update bullets
    for bullet in player.bullets[:]:  # Iterate over a copy of the list
        bullet.update()
        if bullet.y < 0:
            player.bullets.remove(bullet)

    # Check for collisions
    for enemy in enemies[:]:
        if check_collision(player, enemy):
            lives -= 1
            points -= 100
            enemies.remove(enemy)
            if lives <= 0:
                print(f"Game Over! Your final score is {points}.")
                pygame.quit()
                sys.exit()

        for bullet in player.bullets[:]:
            if check_collision(bullet, enemy):
                points += 500
                enemies.remove(enemy)
                player.bullets.remove(bullet)

        enemy.update()
        if enemy.x < 0 - enemy.size:
            enemies.remove(enemy)

    # Update points
    points += 1

    # Add life for every 10,000 points
    if points - last_life_points >= 10000:
        lives += 1
        last_life_points = points

    # Drawing
    window.fill((0, 0, 0))
    player.draw(window)

    for bullet in player.bullets:
        bullet.draw(window)

    for enemy in enemies:
        enemy.draw(window)

    pygame.display.update()
    clock.tick(30)