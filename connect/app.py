from fastapi import FastAPI, Request
import pika
import json

app = FastAPI()

@app.post("/webhook")
async def recibir_alerta(req: Request):
    data = await req.json()

    # Conectar a RabbitMQ
    connection = pika.BlockingConnection(pika.ConnectionParameters('rabbitmq'))
    channel = connection.channel()
    channel.queue_declare(queue='alertas', durable=True)

    # Enviar mensaje a la cola
    description = data["alerts"][0]["annotations"]["description"]
    channel.basic_publish(
        exchange='',
        routing_key='alertas',
        body=json.dumps({"alert": description})
    )

    connection.close()
    return {"status": "OK"}
