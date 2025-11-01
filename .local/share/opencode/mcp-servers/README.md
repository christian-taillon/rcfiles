# Ollama Web Search MCP Server for OpenCode

This directory contains the Ollama Web Search MCP server configured for use with OpenCode.

## Setup

1. Set your Ollama API key as an environment variable:
```bash
export OLLAMA_API_KEY="your_api_key_here"
```

2. Add the MCP configuration to your OpenCode config (`~/.config/opencode/config.json`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "ollama_web_search": {
      "type": "local",
      "command": ["uv", "run", "~/.local/share/opencode/mcp-servers/ollama-web-search.py"],
      "enabled": true,
      "environment": {
        "OLLAMA_API_KEY": "{env:OLLAMA_API_KEY}"
      }
    }
  }
}
```

The script uses `uv run` which automatically installs the required dependencies defined in the script header.

2. Set your Ollama API key as an environment variable:
```bash
export OLLAMA_API_KEY="your_api_key_here"
```

3. Add the MCP configuration to your OpenCode config (`~/.config/opencode/config.json`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "ollama_web_search": {
      "type": "local",
      "command": ["python3", "/home/christian/.local/share/opencode/mcp-servers/ollama-web-search.py"],
      "enabled": true,
      "environment": {
        "OLLAMA_API_KEY": "{env:OLLAMA_API_KEY}"
      }
    }
  }
}
```

## Usage

Once configured, you can use the Ollama web search tools in OpenCode by adding `use ollama_web_search` to your prompts:

```
Search for the latest React documentation and find information about hooks. use ollama_web_search
```

The MCP server provides two tools:
- `web_search`: Search the web using Ollama's hosted search API
- `web_fetch`: Fetch the content of a web page for a provided URL

## Files

- `ollama-web-search.py`: The MCP server script
- `requirements.txt`: Python dependencies
- `ollama-opencode-config.json`: Example OpenCode configuration