FROM python:3.9-slim
WORKDIR /app
COPY app/main.py .
RUN pip install flask
CMD ["python", "main.py"]