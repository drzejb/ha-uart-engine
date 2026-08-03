# UART Engine Architecture

## Cel

UART Engine jest uniwersalnym silnikiem komunikacji.

Nie zna Solato, Modbus ani żadnego konkretnego urządzenia.

Odpowiada wyłącznie za transport danych i obsługę ramek.

---

# Struktura

engine/
engine.py
connection.py
sender.py
receiver.py
framer.py
dispatcher.py
transaction.py
protocol.py
crc.py
exceptions.py
types.py

---

# Odpowiedzialność

## Engine

Fasada.

Udostępnia publiczne API.

Nie zawiera logiki komunikacji.

---

## Connection

- connect()
- disconnect()
- reconnect()
- monitor połączenia

---

## Sender

- kolejka TX
- wysyłanie ramek

---

## Receiver

- odbiór bajtów

---

## Framer

- składanie ramek
- wykrywanie początku i końca

---

## Dispatcher

- przekazywanie ramek
- callbacki
- eventy

---

## Transaction

- request/response
- timeout
- Future
- dopasowanie odpowiedzi

---

## Protocol

Interfejs opisujący protokół.

Implementacje:

- Solato
- Modbus
- ...

---

## CRC

Obliczanie CRC.

---

# Publiczne API

```python
engine = UartEngine(...)

await engine.start()

await engine.stop()

await engine.send(frame)

response = await engine.request(frame)

engine.subscribe(callback)
```

# Zasady

- jedna klasa = jedna odpowiedzialność
- brak zależności od Home Assistanta
- brak zależności od konkretnego protokołu
- cały kod asynchroniczny
- pełne type hinty
- każda klasa testowalna
- żadna klasa nie tworzy innych klas poza Engine (Dependency Injection)