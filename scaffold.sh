printf -v N "%02d" $1
dir="./src/day$N"

mkdir $dir
if [ ! -f "$dir/day$N.zig" ]; then
    cp ./src/template.zig $dir/day$N.zig
fi

aoc download \
    --year 2024\
    --day $N \
    --input-file $dir/input.txt \
    --puzzle-file $dir/puzzle.md \
    -o

touch $dir/example.txt