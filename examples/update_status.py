#!/usr/bin/python3

import pika
import json

url = 'amqps://USER:PASS@rabbit.suse.de?heartbeat_interval=5';
connection = pika.BlockingConnection(pika.URLParameters(url))
channel = connection.channel()
channel.exchange_declare(exchange='pubsub', exchange_type='topic',
                         passive=True, durable=True)
message = json.dumps({'name': 'test', 'status': 'ok'})
channel.basic_publish(exchange='pubsub', routing_key='suse.bot.status',
                      body=message)
connection.close()
