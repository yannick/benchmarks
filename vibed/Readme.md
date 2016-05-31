this version uses etcimon's vibe.d, ddb, memutils and libasync fork
and builds a version that has no external C linkings.

it only works on DMD however!

```
for proj in vibe.d libasync memutils ddb
do
git clone https://github.com/etcimon/$proj.git $proj-etcimon
#dub add-local $proj-etcimon
done
```