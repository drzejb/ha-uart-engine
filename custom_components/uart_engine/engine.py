from __future__ import annotations

import asyncio
import logging

_LOGGER = logging.getLogger(__name__)


class UartEngine:
    def __init__(self, host: str, port: int):
        self._host = host
        self._port = port

        self._reader: asyncio.StreamReader | None = None
        self._writer: asyncio.StreamWriter | None = None

        self._connected = False
        self._connect_task: asyncio.Task | None = None

    @property
    def connected(self) -> bool:
        return self._connected

    async def start(self):
        if self._connect_task is None:
            self._connect_task = asyncio.create_task(self._connect_loop())

    async def stop(self):
        if self._connect_task:
            self._connect_task.cancel()

        if self._writer:
            self._writer.close()
            await self._writer.wait_closed()

        self._connected = False

    async def _connect_loop(self):

        while True:

            try:

                _LOGGER.info(
                    "Connecting to %s:%s...",
                    self._host,
                    self._port,
                )

                self._reader, self._writer = await asyncio.open_connection(
                    self._host,
                    self._port,
                )

                self._connected = True

                _LOGGER.info("Connected.")

                await self._receive_loop()

            except asyncio.CancelledError:
                raise

            except Exception as ex:
                self._connected = False

                _LOGGER.warning(
                    "Connection failed: %s",
                    ex,
                )

                await asyncio.sleep(5)

    async def _receive_loop(self):

        while True:

            data = await self._reader.read(4096)

            if not data:
                raise ConnectionError("Disconnected")

            _LOGGER.debug("RX: %s", data.hex(" "))