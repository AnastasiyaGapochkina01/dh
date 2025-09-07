FROM python:3.11
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
ENTRYPOINT ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]