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

## builtin commands
to find out how to get information on builtin commands, use `help help`

### escape sequences
`\e` escape character (27)

`\$` dollar sign

`\n` newline

`\\` backslash symbol

### tokens
`/u` username

`/h` hostname (unix/linux only)

`/w` current working directory

## customisation
lysh can be customised using the lyshrc file in ~/.config or appdata on windows

### example customisations
__prompt__
```
set LYSH_PROMPT "/u /w$ "
```

__aliases__
```
alias ls "ls --color=auto"
```
this alias will make ls automatically use colour in its output

