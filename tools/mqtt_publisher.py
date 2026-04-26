import random
import time
import argparse

import paho.mqtt.client as mqtt


DEFAULT_BROKER_HOST = "broker.hivemq.com"
DEFAULT_BROKER_PORT = 1883
DEFAULT_TOPIC = "sensor/temperature"
DEFAULT_CLIENT_ID = "temp_publisher_lab4"
DEFAULT_INTERVAL_SECONDS = 5


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default=DEFAULT_BROKER_HOST)
    parser.add_argument("--port", type=int, default=DEFAULT_BROKER_PORT)
    parser.add_argument("--topic", default=DEFAULT_TOPIC)
    parser.add_argument("--client-id", default=DEFAULT_CLIENT_ID)
    parser.add_argument("--interval", type=int, default=DEFAULT_INTERVAL_SECONDS)
    args = parser.parse_args()

    client = mqtt.Client(client_id=args.client_id, protocol=mqtt.MQTTv311)
    client.connect(args.host, args.port, keepalive=20)
    client.loop_start()

    temperature_c = 22.0

    try:
        while True:
            temperature_c += random.uniform(-0.6, 0.6)
            payload = f"{temperature_c:.1f}°C"
            client.publish(args.topic, payload, qos=0, retain=False)
            print(f"Published to {args.topic} on {args.host}:{args.port}: {payload}")
            time.sleep(args.interval)
    except KeyboardInterrupt:
        pass
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()

