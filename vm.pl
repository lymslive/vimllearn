#! /usr/bin/env perl
use strict;
use warnings;
use Text::Markdown qw(markdown);
use FindBin qw($Bin);

my $title = "no title"; 
my $body = "no body";

# 解析 GET 参数
my $query = $ENV{QUERY_STRING};
my %query = map {$1 => $2 if /(\w+)=(\S+)/} split('&', $query);

my $mdpath = $query{p};
response() unless $mdpath;

$mdpath = "$Bin/$mdpath.md";
response() unless -r $mdpath;

my $mdfile = prefile($mdpath);
my $text = join("", @{$mdfile->{content}});
# my $text = join("\n", @{$mdfile->{content}});
# <pre> will add anthor empty line

$title = $mdfile->{title} if $mdfile->{title};
$body = markdown($text, {tab_width => 2});
fixlink();
# postbody();
response();

# read markdown file, save some information with hash
# Text::Markdown fail to handle code block such as
# ```perl
# any code snippet
# ```
sub prefile
{
	my ($filename) = @_;
	my $filemark = {content => [], title => '', tags => [], };
	my $codeblok = 0;

	open(my $fh, '<', $filename) or die "cannot open $filename $!";
	# local $/ = undef; $text = <$fh>;
	while (<$fh>) {
		# chomp;
		# title line
		if ($. == 1) {
			push(@{$filemark->{content}}, $_);
			(my $title = $_ ) =~ s/^[#\s]+//;
			$filemark->{title} = $title;
			next;
		}
		# tag line
		elsif ($. == 2){
			my @tags = /`([^`]+)`/g;
			if (@tags) {
				push(@{$filemark->{tags}}, @tags);
				next;
			}
		}

		# begin/end code block ```perl
		if (/^\s*```(\S*)\s*$/) {
			my $line = $_;
			if (!$codeblok) {
				$line = qq{<pre><code class="language-$1">};
				$codeblok = 1;
			}
			else {
				$line = qq{</code></pre>\n};
				$codeblok = 0;
			}
			push(@{$filemark->{content}}, $line);
		}
		else {
			push(@{$filemark->{content}}, $_);
		}
	}
	close($fh);

	return $filemark;
}

# 回应输出
sub response
{
print "Content-type:text/html\n\n";
print <<EndOfHTML;
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width" />
		<link rel="stylesheet" type="text/css" href="/css/main.css">
		<link rel="stylesheet" type="text/css" href="/css/markdown.css">
		<title> $title </title>
	</head>
	<body>
		$body
	</body>
</html>
EndOfHTML
}

sub debug_query
{
	$body = "";
	while (my ($key, $value) = each %query) {
		$body .= "$key => $value<br/>";
	}
}

sub postbody
{
	$body .= qq{<hr>\n};
	for my $tag (@{$mdfile->{tags}}) {
		$body .= qq{<code>$tag</code> };
	}
}

# fix links from/to home content and prev/next pages
sub fixlink
{
	my $base = $ENV{SCRIPT_NAME};
	my $subname = $query{p};
	if ($subname =~ /^content$/) {
		$body =~ s/href="(.+)\.md"/href="$base?p=$1"/g;
	}
	else {
		my ($prev, $next) = findprenext($subname);
		my @foot = ();

		push(@foot, "<hr/>");
		$prev ? push(@foot, qq{<a href="$base?p=$prev">Prev</a>})
			: push(@foot, qq{<a>First</a>});
		push(@foot, qq{<a href="$base?p=content">| Home |</a>});
		$next ? push(@foot, qq{<a href="$base?p=$next">Next</a>})
			: push(@foot, qq{<a>Last</a>});

		$body .= sprintf(qq{\n<div class="foot-link"> %s \n</div>\n}, join("\n", @foot));
	}
}

# read content.md, find the prev/next page
sub findprenext
{
	my $curname = shift;
	my ($prev, $next) = ('', '');

	my $tocname = "$Bin/content.md";
	return ($prev, $next) unless -f $tocname;

	open(my $fh, '<', $tocname) or die "cannot open $tocname $!";
	my ($prev_may, $cur_may);
	while (<$fh>) {
		chomp;
		next unless /\((\S+)\.md\)/;
		$prev_may = $cur_may;
		$cur_may = $1;
		if ($cur_may eq $curname) {
			$prev = $prev_may;
			next;
		}
		if ($prev_may eq $curname) {
			$next = $cur_may;
			last;
		}
	}
	close($fh);

	return ($prev, $next);
}
