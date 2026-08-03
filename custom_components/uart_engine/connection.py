from __future__ import annotations

import asyncio
import logging

_LOGGER = logging.getLogger(__name__)


class Connection:
    """TCP connection."""

    def __init__(
            self,
            host: str,
            port: int,
            connect_timeout: float = 10.0,
    ) -> None:
        self._host = host
        self._port = port
        self._connect_timeout = connect_timeout

        self._reader: asyncio.StreamReader | None = None
        self._writer: asyncio.StreamWriter | None = None

    @property
    def connected(self) -> bool:
        return (
                self._writer is not None
                and not self._writer.is_closing()
        )

    @property
    def reader(self) -> asyncio.StreamReader:
        if self._reader is None:
            raise RuntimeError("Connection is not established.")

        return self._reader

    async def connect(self) -> None:
        """Open TCP connection."""

        if self.connected:
            return

        _LOGGER.info(
            "Connecting to %s:%s...",
            self._host,
            self._port,
        )

        self._reader, self._writer = await asyncio.wait_for(
            asyncio.open_connection(
                self._host,
                self._port,
            ),
            timeout=self._connect_timeout,
        )

        _LOGGER.info(
            "Connected to %s:%s",
            self._host,
            self._port,
        )

    async def disconnect(self) -> None:
        """Close TCP connection."""

        if self._writer is None:
            return

        _LOGGER.info(
            "Disconnecting from %s:%s...",
            self._host,
            self._port,
        )

        self._writer.close()

        try:
            await self._writer.wait_closed()
        finally:
            self._reader = None
            self._writer = None

        _LOGGER.info("Disconnected.")

    async def reconnect(self) -> None:
        """Reconnect."""

        await self.disconnect()
        await self.connect()

    async def send(self, data: bytes) -> None:
        """Send bytes."""

        if not self.connected:
            raise ConnectionError("Not connected.")

        assert self._writer is not None

        self._writer.write(data)
        await self._writer.drain()

    async def receive(self, size: int = 4096) -> bytes:
        """Receive bytes."""

        if not self.connected:
            raise ConnectionError("Not connected.")

        assert self._reader is not None

        data = await self._reader.read(size)

        if not data:
            await self.disconnect()
            raise ConnectionError("Connection closed by remote host.")

        return data