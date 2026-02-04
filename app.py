import os
import socket
from flask import Flask
import redis

app = Flask(__name__)

@app.route('/')
def home():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>DevOps Store</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            button { padding: 10px 20px; font-size: 16px; cursor: pointer; }
            #response { margin-top: 20px; font-weight: bold; }
        </style>
    </head>
    <body>
        <h1>Welcome to the DevOps Store! v2</h1>
        <button onclick="placeOrder()">Place Order</button>
        <div id="response"></div>
        
        <script>
            async function placeOrder() {
                const responseDiv = document.getElementById('response');
                responseDiv.textContent = 'Processing...';
                
                try {
                    const response = await fetch('/buy');
                    const result = await response.text();
                    responseDiv.textContent = result;
                } catch (error) {
                    responseDiv.textContent = 'Error placing order';
                }
            }
        </script>
    </body>
    </html>
    '''

@app.route('/buy')
def buy():
    try:
        redis_host = os.getenv('REDIS_HOST', 'localhost')
        redis_port = int(os.getenv('REDIS_PORT', 6379))
        
        r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)
        r.ping()
        
        order_count = r.incr('order_count')
        hostname = socket.gethostname()
        return f"Order placed! Total orders: {order_count} (Handled by: {hostname})"
    except redis.exceptions.ConnectionError:
        return "Database unavailable, but App is running!"
    except Exception as e:
        return "Database unavailable, but App is running!"
    
import math

@app.route('/heavy')
def heavy_load():
    # Simulate CPU intensive task
    n = 1000000
    while n > 0:
        n -= 1
        math.sqrt(n)
    return "CPU Burned Successfully!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
