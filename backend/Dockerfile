# Dockerfile.backend
FROM python:3.11-slim-bookworm

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . . 
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 8000

ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]