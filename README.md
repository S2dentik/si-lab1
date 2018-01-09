# SI Lab 1

## Usage

```shell
➜  MacOS ./Lab1
Usage:

    $ ./Lab1

Commands:

    + send
    + listen
    + proxy
    + file
```

## Commands

To get a detailed description for each command, run `./Lab1 <command> --help`

```shell
➜  MacOS ./Lab1 send --help
Usage:

    $ ./Lab1 send <address> <port> <message>

Arguments:

    address - Destination IP address
    port - Destination port
    message - Message to send

Options:
    --repeat_interval - The interval at which to repeatedly send the message
    --max_repeat_times [default: 1] - Maximum number of times to repeatedly send the message
```