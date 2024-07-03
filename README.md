# Инструкция по запуску приложения

## Предварительные требования

Для запуска данного приложения вам понадобятся следующие инструменты:

- Git
- Docker
- Docker Compose



## 1. Клонируйте основной репозиторий вместе с подмодулями:
```
git clone --recurse-submodules https://github.com/ChaoticGoodAdmi/OtusHub.git
```

Для корректной работы приложения переменные среды уже заданы, но их можно изменить по желанию.

## 2. Перейдите в корневую директорию проекта, если вы еще не там:
```
    cd Highload
```

## 3. Соберите и запустите Docker-контейнеры:
```
    docker-compose up --build
```

Эта команда выполнит следующие шаги:

- Соберет контейнеры для всех сервисов (backend, frontend, postgres).
- Запустит контейнеры в соответствии с конфигурацией, указанной в `docker-compose.yml`.

## Описание параметров среды

### Backend (Spring Boot):

В OtusHub сервисе необходимо указать переменные среды, которые уже заданы в Dockerfile:

    ```dockerfile
    ENV SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/otushub
    ENV SPRING_DATASOURCE_USERNAME=postgres
    ENV SPRING_DATASOURCE_PASSWORD=postgres
    ENV jwt.secret=your_jwt_secret_key
    ENV SERVICE_URL=http://localhost:4242
    ```

### Frontend (React):

Переменная среды для frontend задается в файле `.env`:
```env
    REACT_APP_API_BASE_URL=http://localhost:4242
```

### Проверка работы приложения

## Запустите React приложение по адресу
```
http://localhost:3030
```

## Или используйте один из следующих запросов для работы с backend-ом:


### [Коллекция Postman-запросов](https://github.com/ChaoticGoodAdmi/OtusHub/blob/master/src/main/resources/otushub.postman_collection.json)

### Альтернатива: cUrl запросы

#### Регистрация пользователя (валидация данных и сохранение пользователя в БД)

*Необходимо поменять данные в теле запроса на нужные*
**Требования:**

1. все поля не пустые
2. birthDate: в формате "YYYY-MM-DD" должна быть в прошлом
3. sex: "MALE" или "FEMALE"
4. biography: не длиннее 200 символов`

```bash
curl -X POST http://localhost:4242/user/register \
    -H "Content-Type: application/json" \
    -d '{
          "firstName": "Kirill",
          "secondName": "Ushakov",
          "birthDate": "1990-05-03",
          "sex": "MALE",
          "biography": "A software developer with over 4 years of experience in backend development.",
          "city": "Vladimir",
          "password": "securepassword123"
        }'
```

#### Аутентификация пользователя по userId и password

*Необходимо поменять данные в теле запроса на нужные*
**Требования:**

1. userId: подставить UUID, сгенерированный при выполнении метода user/register
2. password: тот же пароль, что использовался в теле запроса в user/register

```bash
curl -X POST http://localhost:4242/login \
    -H "Content-Type: application/json" \
    -d '{
          "userId": "ea2915",
          "password": "securepassword123"
        }'
```

#### Получение анкетных данных пользователя по UserId

*Необходимо поменять данные в URL и в заголовке Authentication на нужные*
**Требования:**

1. userId: подставить UUID, сгенерированный при выполнении метода user/register в URL запроса
2. Headers: в заголовке запроса Authentication вставить токен, полученный при выполнении сервиса /login после "Bearer<
   пробел>"

```bash
curl -X GET http://localhost:4242/user/get/ea2915 \
    -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJlYTI5MTUiLCJpYXQiOjE3MjAwMDIyMzQsImV4cCI6MTcyMDA4ODYzNH0.Q456enA8phHL7VhMSr7u4ec12xTMcK1Fi1_6eSpzCK8XCc3WjFHfzFTs_q2_qxjZ3ighJF1_19pjLes9Mx1TbQ"
```

#### Health Check

```bash
curl -X GET http://localhost:4242/actuator/health
```

Следуя этим шагам, вы сможете успешно запустить и проверить работу данного приложения.
