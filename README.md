# find-reverse

find-reverse is a small tool to find the closest ancestor directory that provides a searched file name.

## Usage

```
find-reverse [-d path] [--default path] <file names>
```

-d | --default:
  default directory if no file could be found
  
  By the default this is "/".
  
## Example:

```
/
|__ home
....|__ user
........|__ foo
............|__ baz1
............|__ baz2
................|__ blub
........|__bar
```

```
cd /home/user/foo/baz2
find-reverse bulb
--> /home/user/foo/baz2

cd /home/user/foo/baz2
find-reverse bar
--> /home/user

cd /home/user/foo/baz2
find-reverse -d "I love cookies" "Cookie"
--> I love cookies
```
