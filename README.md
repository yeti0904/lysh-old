# lysh

Light Yeti Shell

## compile
```
dub build
```

### dependencies
readline

## syntax
variables: `$(variable_name)`

redirect output `command > filename`

### escape sequences
`\e` escape character (27)

`\$` dollar sign

`\n` newline

`\\` backslash symbol

### tokens
`/u` username

`/h` hostname (unix/linux only)

`/w` current working directory
