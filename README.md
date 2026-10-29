# get_time

A small, fast command-line tool written in [Mojo](https://www.modular.com/mojo) that
gives AI agents and automation scripts what language models can't do on their own:
know the current time and do date math correctly.

LLMs have no clock. They guess the date from training data and often get relative
time wrong ("in 3 days and 4 hours" is easy to fumble). `get_time` hands that job to
real code, so your agent gets a correct answer instead of a plausible one.

## Why use it with AI tooling

- **Ground-truth timestamps**: stamp logs, memory entries, and tool outputs with the
  actual system time rather than a model's guess.
- **Exact deadlines and reminders**: compute "now + 2 hours" or "now + 1 week" in a
  single call, then feed the result into a scheduler, cron entry, or alert.
- **Alert-ready building block**: pair it with any notifier or task queue to set
  trigger times, expiry windows, and follow-up reminders.
- **Agent-friendly interface**: one command, plain-text output, no setup or API keys.
  Easy to expose as a tool in any agent framework that can run a shell command.
- **Low overhead**: compiled Mojo startup is cheap, so it's fine to call as often as
  an agent loop needs.
- **Token-efficient**: ask for only the fields you need (`--time Y m d H M`) instead
  of parsing a long date string.
- **Familiar format codes**: uses standard `strftime` codes, which models already
  know how to write.

## Usage

    # Timestamp for a log line or memory entry
    get_time --time Y m d H M S

    # Current weekday and timezone, for context in a prompt
    get_time --time A Z

    # When should this reminder fire? (3 days and 2 hours from now)
    get_time --date days=3 hours=2

    # Expiry time one week out
    get_time --date weeks=1

    # Full list of supported codes and units
    get_time --help

## Options

| Flag | Description |
|------|-------------|
| `--time CODE [CODE ...]` | One or more `strftime`-style codes (`Y`, `m`, `d`, `H`, `Z`, ...) |
| `--date UNIT=VALUE [...]` | Offset from now. Units: `days`, `hours`, `minutes`, `seconds`, `milliseconds`, `microseconds`, `weeks` |
| `-h`, `--help` | Show usage and all supported codes |

## Requirements

- Mojo
- Python 3 available to Mojo's interop
