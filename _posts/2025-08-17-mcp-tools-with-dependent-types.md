---
layout: post
title: "MCP tools with dependent&nbsp;types"
description: "After some experimenting with writing an MCP server and using LLM APIs with structured output, I think there is room for improvement for the MCP specification."
---

This summer, I've been playing a bit with writing [an MCP server](https://gist.github.com/vlaaad/395bd021e8a4ba6561fd4f8d3562456f) for [Defold](https://defold.com/) editor. The idea was to give Claude access to evaluating Lua code in the editor scripting context, so it can use the APIs available for querying and modifying game content. The best word to describe the experience is **entertaining** — it has a very vague idea of the available APIs, and prefers to experiment by evaluating code instead of browsing documentation, which results in low accuracy and a need to steer it:

![](/assets/mcp-tools-with-dependent-types/claude.png)

It was entertaining because it was inaccurate, but still trying really hard, and eventually succeeding. I think, as novelty wears off and agentic LLM approaches mature, the need for accuracy will increase dramatically — this "entertainment" will become an annoying bug.

Of course, there is already a solution for this inaccuracy: every LLM service worth its salt supports structured outputs defined by JSON schemas; in the context of MCP, it means that tools define [input schemas](https://modelcontextprotocol.io/specification/2025-06-18/server/tools#tool), and it's a responsibility of the AI agent to construct an input satisfying the schema. For example, here is a tool definition:
```json
{
  "name": "get_weather",
  "inputSchema": {
    "type": "object",
    "properties": {
      "location": {"type": "string"}
    },
    "required": ["location"]
  }
}
```
By the way, since tools are essentially functions, the same thing can be written in a more concise way, which I think fits better for this post:
```lua
get_weather({location: string})
```

# The problem

As soon as I started thinking about designing proper tools with JSON schemas for Defold, I hit an issue. There is something you can easily do with structured outputs if you make your own integrated LLM chat, that you can't do in MCP: resolving input JSON schemas dynamically. Or, in programming terms, there is no way to define generic functions with dependent types:
```lua
edit_resource({resource: string, props: PropsOf resource})
```
Simple example tools like `get_weather` have well-defined inputs. In more complex domains, it's common to have data shapes that can only be known at the time of use. In Defold, 3D models refer to GLTF files, GLTF files define material names; Defold supports selecting a material for each name, where, finally, each material may define 0 or more textures. This means that 2 different model files might have different properties depending on the selected GLTF models and assigned materials. For example, compare properties of a sphere model with default material to properties of a sphere model with [PBR](https://github.com/defold/defold-pbr) material:

![](/assets/mcp-tools-with-dependent-types/props.png)

How would you define an MCP tool for editing such models? I don't see a way, to be honest.

# The solution

The proper solution for editing complex models using LLMs with structured output would be to make it a 2-step process:
1. LLM selects a resource to edit. At this point, the program looks up the data shape of a resource and constructs a JSON schema. 
2. LLM generates an edit using a constructed JSON schema.

As I said earlier, this is possible to do if you are building a custom AI chat interface for your program. But it's not possible with MCP — there is no way to tell the AI agent "for this argument, look up a JSON schema using this other tool". It could be defined like that:
```json
// edit resource tool
{
  "name": "edit_resource",
  "inputSchema": {
    "type": "object",
    "properties": {
      "resource": {"type": "string"},
      "props": {
        // dependent type, also valid JSON schema
        "x-schemaTool": "get_resource_schema", 
        "x-schemaToolArgs": ["resource"]
      }
    },
    "required": ["resource", "props"]
  }
}
// tool that returns JSON schema
{
  "name": "get_resource_schema",
  "inputSchema": {
    "type": "object",
    "properties": {
      "resource": {"type": "string"}
    },
    "required": ["resource"]
  }
}
```
Perhaps, MCP should support something like that?