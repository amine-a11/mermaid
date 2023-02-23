# Directives

## Directives

Directives gives a diagram author the capability to alter the appearance of a diagram before rendering by changing the applied configuration.

The significance of having directives is that you have them available while writing the diagram, and can modify the default global and diagram specific configurations. So, directives are applied on top of the default configurations. The beauty of directives is that you can use them to alter configuration settings for a specific diagram, i.e. at an individual level.

While directives allow you to change most of the default configuration settings, there are some that are not available, that too for security reasons. Also, you do have the _option to define the set of configurations_ that you would allow to be available to the diagram author for overriding with help of directives.

## Types of Directives options

Mermaid basically supports two types of configuration options to be overridden by directives.

1. _General/Top Level configurations_ : These are the configurations that are available and applied to all the diagram. **Some of the most important top-level** configurations are:

- theme
- fontFamily
- logLevel
- securityLevel
- startOnLoad
- secure

2. _Diagram specific configurations_ : These are the configurations that are available and applied to a specific diagram. For each diagram there are specific configuration that will alter how that particular diagram looks and behaves.
   For example, `mirrorActors` is a configuration that is specific to the `SequenceDiagram` and alter whether the actors are mirrored or not. So this config is available only for the `SequenceDiagram` type.

**NOTE:** These options listed here are not all the configuration options. To get hold of all the configuration options, please refer to the [defaultConfig.ts](https://github.com/mermaid-js/mermaid/blob/develop/packages/mermaid/src/defaultConfig.ts) in the source code.

```note
We plan to publish a complete list of top-level configurations & all the diagram specific configurations, with their possible values in the docs soon.
```

## Declaring directives

Now that we have defined the types of configurations that are available, we can learn how to declare directives.
A directive always starts and end `%%` sign with directive text in between, like `%% {directive_text} %%`.

Here the structure of a directive text is like a nested key-value pair map or a JSON object with root being _init_. Where all the general configurations are defined in the top level, and all the diagram specific configurations are defined one level deeper with diagram type as key/root for that section.

Following code snippet shows the structure of a directive:

```
%%{
  init: {
    "theme": "dark",
    "fontFamily": "monospace",
    "logLevel": "info",
    "flowchart": {
      "htmlLabels": true,
      "curve": "linear"
    },
    "sequence": {
      "mirrorActors": true
    }
  }
}%%
```

You can also define the directives in a single line, like this:

```
%%{init: { **insert argument here**}}%%
```

For example, the following code snippet:

```
%%{init: { "sequence": { "mirrorActors":false }}}%%
```

**Notes:**
The json object that is passed as {**argument** } must be valid key value pairs and encased in quotation marks or it will be ignored.
Valid Key Value pairs can be found in config.

Example with a simple graph:

```mermaid-example
%%{init: { 'logLevel': 'debug', 'theme': 'dark' } }%%
graph LR
A-->B
```

Here the directive declaration will set the `logLevel` to `debug` and the `theme` to `dark` for a rendered mermaid diagram, changing the appearance of the diagram itself.

Note: You can use 'init' or 'initialize' as both acceptable as init directives. Also note that `%%init%%` and `%%initialize%%` directives will be grouped together after they are parsed. This means:

```mmd
%%{init: { 'logLevel': 'debug', 'theme': 'forest' } }%%
%%{initialize: { 'logLevel': 'fatal', "theme":'dark', 'startOnLoad': true } }%%
...
```

parsing the above generates a single `%%init%%` JSON object below, combining the two directives and carrying over the last value given for `loglevel`:

```json
{
  "logLevel": "fatal",
  "theme": "dark",
  "startOnLoad": true
}
```

This will then be sent to `mermaid.initialize(...)` for rendering.

## Directive Examples

More directive examples for diagram specific configuration overrides
Now that the concept of directives has been explained, Let us see some more examples for directives usage:

### Changing Theme via directive

The following code snippet changes theme to forest:

`%%{init: { "theme": "forest" } }%%`

Possible themes value are: `default`,`base`, `dark`, `forest` and `neutral`.
Default Value is `default`.

Example:

```mermaid-example
%%{init: { "theme": "forest" } }%%
graph TD
A(Forest) --> B[/Another/]
A --> C[End]
  subgraph section
  B
  C
  end

```

### Changing fontFamily via directive

The following code snippet changes fontFamily to rebuchet MS, Verdana, Arial, Sans-Serif:

`%%{init: { "fontFamily": "Trebuchet MS, Verdana, Arial, Sans-Serif" } }%%`

Example:

```mermaid-example
%%{init: { "fontFamily": "Trebuchet MS, Verdana, Arial, Sans-Serif" } }%%
graph TD
A(Forest) --> B[/Another/]
A --> C[End]
  subgraph section
  B
  C
  end

```

### Changing logLevel via directive

The following code snippet changes logLevel to 2:

`%%{init: { "logLevel": 2 } }%%`

Possible logLevel values are:

- `1` for _debug_,
- `2` for _info_
- `3` for _warn_
- `4` for _error_
- `5` for _only fatal errors_

Default Value is `5`.

Example:

```mermaid-example
%%{init: { "logLevel": 2 } }%%
graph TD
A(Forest) --> B[/Another/]
A --> C[End]
  subgraph section
  B
  C
  end
```

### Changing flowchart config via directive

Some common flowchart configurations are:

- _htmlLabels_: true/false
- _curve_: linear/curve
- _diagramPadding_: number
- _useMaxWidth_: number

For complete list of flowchart configurations, see [defaultConfig.ts](https://github.com/mermaid-js/mermaid/blob/develop/packages/mermaid/src/defaultConfig.ts) in the source code.
_Soon we plan to publish a complete list all diagram specific configurations updated in the docs_

The following code snippet changes flowchart config:

`%%{init: { "flowchart": { "htmlLabels": true, "curve": "linear" } } }%%`

Here were are overriding only the flowchart config, and not the general config, where HtmlLabels is set to true and curve is set to linear.

```mermaid-example
%%{init: { "flowchart": { "htmlLabels": true, "curve": "linear" } } }%%
graph TD
A(Forest) --> B[/Another/]
A --> C[End]
  subgraph section
  B
  C
  end
```

### Changing Sequence diagram config via directive

Some common sequence configurations are:

- _width_: number
- _height_: number
- _messageAlign_: left, center, right
- _mirrorActors_: boolean
- _useMaxWidth_: boolean
- _rightAngles_: boolean
- _showSequenceNumbers_: boolean
- _wrap_: boolean

For complete list of sequence diagram configurations, see _defaultConfig.ts_ in the source code.
_Soon we plan to publish a complete list all diagram specific configurations updated in the docs_

So, `wrap` by default has a value of `false` for sequence diagrams.

Let us see an example:

```mermaid-example
sequenceDiagram

Alice->Bob: Hello Bob, how are you?
Bob->Alice: Fine, How did you mother like the book I suggested? And did you catch with the new book about alien invasion?
Alice->Bob: Good.
Bob->Alice: Cool
```

Now let us enable wrap for sequence diagrams.

The following code snippet changes sequence diagram config for `wrap` to `true`:

`%%{init: { "sequence": { "wrap": true} } }%%`

Using in the diagram above, the wrap will be enabled.

```mermaid-example
%%{init: { "sequence": { "wrap": true, "width":300 } } }%%
sequenceDiagram
Alice->Bob: Hello Bob, how are you?
Bob->Alice: Fine, How did you mother like the book I suggested? And did you catch with the new book about alien invasion?
Alice->Bob: Good.
Bob->Alice: Cool
```