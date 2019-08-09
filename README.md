# scan

From the s/w architecture perspective it's better to have the analysis as a separate docker image - just a python script in a container.
But from ease of use, security point of view, and the cluttering of the underlying system, it makes sense to just have one large image that does everything.
First, if you are going to save and then import a docker image because that's the only way to get the image there, then it's best to do it just once.
Second, one thing the benchmark tests for is how many images are on the system and every image we add counts towards that.
For these two reasons making an image that does all the scans and analysis.

The containerized docker-bench works better than the shell-script on the host now - but as the underlying NC changes, new issues may show up.
So would should run the compare script prior to each quarterly scan to make sure it's always working as good as or better than the shell script on the host.

The scripts in this directory are either executed on the host, or in the container. The scripts on the host should assume minimal packages.
So sh or bash scripts are fine, but we don't want to assume that python is installed. The scripts on the container can use anything, but in
the long run we want to optimize for as few processes as possible, and possibility of using other images. So sh and python are fine, but
avoiding bash is for example a good idea because it's not there on alpine based images.

The purpose of Makefile is to document various useful command - sort of an executable README. It doesn't have to be perfect and build everything.
It's more of a documentation tool than anything else.
