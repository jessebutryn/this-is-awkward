# this-is-awkward

This is a low level demo on some of the common and useful things I find myself
doing with `awk`.

## Topics

- Built-in variables
- Using `$n`
- Searching
- Other filtering
- Formatting output
- Shell variables
- BEGIN/END

### Built-in variables

#### `ARGC`

Number of command line arguments

#### `ARGV`

An array that stores command line arguments

```
$ awk 'BEGIN {
   for (i = 0; i < ARGC - 1; ++i) {
      printf "ARGV[%d] = %s\n", i, ARGV[i]
   }
}' one two three four
ARGV[0] = awk
ARGV[1] = one
ARGV[2] = two
ARGV[3] = three
```

#### `ENVIRON`

An associative array that stores environmental variables

```
$ FOO=bar awk 'BEGIN{ print ENVIRON["FOO"] }'
bar
```

#### `FILENAME`

Prints filename being read.  Not available in BEGIN block.

```
$ awk 'END{print FILENAME}' README.md
README.md
```

#### `FS`

Holds the field separator that will be used to parse input.  Default is space.
This can also be modified with the `-F` argument.

#### `NF`

Represents the number of fields in the current record. 

```
$ echo 'one two three' | awk '{print NF}'
3
```

Can also be used to print the last field

```
$ echo 'one two three' | awk '{print $NF}'
three
```

Or the second to last field, etc

```
$ echo 'one two three' | awk '{f=NF-1; print $f}'
two
```

#### `NR`

Holds the current record (line number).

Can be used to skip the header line

```
awk 'NR > 1 {blah}' ...
```

#### `OFS`

Output field separator.  Used to format output.  Default is space.

```
$ echo 'one two three' | awk '{OFS=","; print $1,$2,$3}'
one,two,three
```

#### `ORS`

Output record separator.  Similar to OFS but the separator that should separate
records rather than fields.  Default is a newline.

```
$ printf 'one two three\n four five six\n' | awk '{ORS=":"}1'
one two three: four five six:
```

### Using `$n`

The most common and arguably the main use for awk is reading field separated
input.  

```
awk -F, 'NR>1{print $1}' sample-input/sample.csv
```

### Searching

A thing I often see is people piping `grep` into `awk` in order to filter out
some values and then work with the fields.  However awk is perfectly capable
of searching and filtering data natively. 

#### Regex match

You can perform a generic regex match quite simply with the following:

```
awk '$0 ~ /dell/{print}' sample-input/sample.csv
```

That command is written explicitly to show more of what it's doing but it can
be shortened quite a bit with:

```
awk '/dell/' sample-input/sample.csv
```

Additionally if you only wanted to search for a pattern within a specific field
you would do the following:

```
awk -F, '$3 ~ /supermicro/' sample-input/sample.csv
```

#### Exact match

Similar to regex matching you can perform an exact match using the `==`
operator instead of `~`.

```
awk -F: '$NF == "/bin/false"' sample-input/passwd
```

#### Multiple matches

You can perform more complex matching using the `&&` or `||` operators.

```
awk -F, '$3 == "dell" && $4 == "1.10"' sample-input/sample.csv
```

### Other filtering

Similar to searching you can perform filtering based on standard operators.

For example if I want to list only system accounts in my /etc/passwd file:

```
awk -F: '$3 > 99' sample-input/passwd
```

Or if I want to list ONLY system accounts:

```
awk -F: '$3 < 100' sample-input/passwd
```

You can even filter out start and end points based on expressions

```
awk 'NR == 2, NR == 5' sample-input/sample.csv
```

### Formatting output

awk's default behavior is to `print $0`, so if you only do filtering and don't
include any program then any record matching your filter will be printed in
it's entirety. Alternatively you can use print or printf to format your output
how you desire.

#### `print`

`print` can take a list of comma separated arguments and will print them using
`OFS` as a field separator.

```
echo one two three | awk '{print $1,$3}'
```

```
echo one two three | awk -v OFS=: '{print $1,$3}'
```

#### `printf`

In addition to `print`, awk also includes a fairly standard version of `printf`
(also `sprintf` fwiw):

```
echo one 2 3.0 | awk '{printf "First: %s, Second: %d, Third: %.5f\n", $1, $2, $3}'
```

### Shell variables

If you find yourself needing to pass a shell variable into an awk program you
need not worry about some obfuscated quoting.  You can perform this task fairly
easily using the `-v` option.

```
var='2.20'
awk -F, -v version="$var" '$4 == version' sample-input/sample.csv
```

### BEGIN/END

awk programs can have BEGIN and/or END statements.  A BEGIN statement will be
executed only once before any records are read, and conversely an END statement
will be executed only once after all records are read.

```
awk -F, 'BEGIN{
    printf "Firmware count by version\n"
} {
    if ($3 == "dell") {
        if ($4 == "1.10") {
            dell_1_10++
        } else if ($4 == "1.20") {
            dell_1_20++
        } else if ($4 == "2.10") {
            dell_2_10++
        } else if ($4 == "2.20") {
            dell_2_20++
        } else {
            dell_unknown++
        }
    } else if ($3 == "supermicro") {
        if ($4 == "1.10") {
            supermicro_1_10++
        } else if ($4 == "1.20") {
            supermicro_1_20++
        } else if ($4 == "2.10") {
            supermicro_2_10++
        } else if ($4 == "2.20") {
            supermicro_2_20++
        } else {
            supermicro_unknown++
        }
    } else if ($3 == "asrockrack") {
        if ($4 == "1.10") {
            asrockrack_1_10++
        } else if ($4 == "1.20") {
            asrockrack_1_20++
        } else if ($4 == "2.10") {
            asrockrack_2_10++
        } else if ($4 == "2.20") {
            asrockrack_2_20++
        } else {
            asrockrack_unknown++
        }
    }
} END {
    printf "Dells with v1.10: %d\n", dell_1_10
    printf "Supermicros with v1.10: %d\n", supermicro_1_10
    printf "Asrockracks with v1.10: %d\n", asrockrack_1_10
}' sample-input/sample.csv
