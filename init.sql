CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(128) NOT NULL
);

CREATE TABLE IF NOT EXISTS tracks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    difficulty VARCHAR(20)
);

INSERT INTO tracks (name, description, difficulty) VALUES
('Гора Волчья', 'Техничная трасса с множеством поворотов', 'Средняя'),
('Спуск Орла', 'Высокоскоростной спуск с длинными прямыми', 'Высокая'),
('Лесная тропа', 'Живописный маршрут через лес', 'Низкая');