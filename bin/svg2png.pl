use File::Basename;

if (@ARGV!=1) {die"Usage: *.pl <svg_path>\n";exit;}
$bin=dirname $0;
$bin=~s/bin$/software/;
@svg=glob "$ARGV[0]/*.svg";
foreach $svg (@svg) {
	$png=$svg;
	$png=~s/svg$/png/;
	system "$bin/CairoSVG-1.0.9/cairosvg.py -f png $svg -o $png";
}
