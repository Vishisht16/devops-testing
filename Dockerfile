FROM python:3.12.12-alpine3.23

WORKDIR /app

RUN apk update && apk upgrade --no-cache

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
