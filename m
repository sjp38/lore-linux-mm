Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EE04B6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 02:38:25 -0400 (EDT)
References: <20110804143844.GQ19099@suse.de>
Message-ID: <1312526302.37390.YahooMailNeo@web162009.mail.bf1.yahoo.com>
Date: Thu, 4 Aug 2011 23:38:22 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Re: MMTests 0.01
In-Reply-To: <20110804143844.GQ19099@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Dear Mel Gorman,=0A=A0=0AThank you very much for this MMTest. =0AIt will be=
 very helpful for me for all my needs.=0AI was looking forward for these ki=
nd of mm test utilities.=0A=A0=0AJust wanted to know, if any of these utili=
ties also covers anti-fragmentation represent of the=A0various page state i=
n the form of jpeg image?=0AI am specifically looking for this one.=0A=A0=
=0A=A0=0A=A0=0AThanks,=0APintu Kumar=0A=A0=0A=A0=0AFrom: Mel Gorman <mgorma=
n@suse.de>=0ATo: linux-mm@kvack.org=0ACc: linux-kernel@vger.kernel.org=0ASe=
nt: Thursday, 4 August 2011 8:08 PM=0ASubject: MMTests 0.01=0A=0AAt LSF/MM =
at some point a request was made that a series of tests be=0Aidentified tha=
t were of interest to MM developers and that could be=0Aused for testing th=
e Linux memory management subsystem. At the time,=0AI was occasionally post=
ing tarballs of whatever scripts I happened to=0Abe using at the time but t=
hey were not generally usable and tended to=0Abe specific to a set of patch=
es. I promised I would produce something=0Ausable by others but never got a=
round to it. Over the last four months,=0AI needed a better framework when =
testing against both distribution=0Akernels and mainline so without further=
 ado=0A=0Ahttp://www.csn.ul.ie/~mel/projects/mmtests/=0Ahttp://www.csn.ul.i=
e/~mel/projects/mmtests/mmtests-0.01-mmtests-0.01.tar.gz=0A=0AI am not clai=
ming that this is comprehensive in any way but it is=0Aalmost always what I=
 start with when testing patch sets. In preparation=0Afor identifying probl=
ems with backports, I also ran a series of tests=0Aagainst mainline kernels=
 over the course of two months when machines=0Awere otherwise idle. I have =
not actually had a chance to go through=0Aall the results and identify each=
 problem but I needed to have the=0Araw data available for my own reference=
 so might as well share.=0A=0Ahttp://www.csn.ul.ie/~mel/projects/mmtests/re=
sults/SLES11sp1/=0Ahttp://www.csn.ul.ie/~mel/projects/mmtests/results/openS=
USE11.4/=0A=0AThe directories refer to the distribution used but not the=0A=
kernel which is downloaded from kernel.org. Directory structure is=0Adistro=
/config/machine/comparison.html. For example a set of benchmarks=0Aused for=
 evaluating the page and slab allocators on a test machine=0Acalled "hydra"=
 is located at=0A=0Ahttp://www.csn.ul.ie/~mel/projects/mmtests/results/SLES=
11sp1/global-dhp__pagealloc-performance/hydra/comparison.html=0A=0AI know t=
he report structure looks crude but I was not interested=0Ain making them p=
retty. Due to the fact that some of the scripts=0Aare extremely old, the qu=
ality and coding styles vary considerably.=0AThis may get cleaned up over t=
ime but in the meantime, try and keep=0Athe contents of your stomach down i=
f you are reading the scripts.=0A=0AThe documentation is not great and so s=
ome of the capabilities such=0Aas being able to reconfigure swap for a benc=
hmark is not mentioned.=0AFor my own series, I'll relase the mmtests tarbal=
l I used if asked.=0AIf someone wants to use the tarball for their own test=
ing but cannot=0Aconfigure it, complain on the linux-mm list and if I can, =
I'll offer=0Asuggestions.=0A=0A=3D=3D=3D=3D MMTests README =3D=3D=3D=3D=0A=
=0AMMTests is a configurable test suite that runs a number of common=0Awork=
loads of interest to MM developers. Ideally this would have been=0Ato integ=
rated with LTP, xfstests or Phoronix Test or implemented=0Awith autotest.=
=A0 Unfortunately, large portions of these tests are=0Acobbled together ove=
r a number of years with varying degrees of=0Aquality before decent test fr=
ameworks were common.=A0 The refactoring=0Aeffort to integrate with another=
 framework is significant.=0A=0AOrganisation=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=0A=0AThe top-level directory has a single driver script called=0A=
run-mmtests.sh which reads a config file that describes how the=0Abenchmark=
s should be run, configures the system and runs the requested=0Atests. conf=
ig also has some per-test configuration items that can be=0Aset depending o=
n the test. The driver script takes the name of the=0Atest as a parameter. =
Generally, this would be a symbolic name naming=0Athe kernel being tested.=
=0A=0AEach test is driven by a run-single-test.sh script which reads=0Athe =
relevant driver-TESTNAME.sh script. High level items such as=0Aprofiling ar=
e configured from the top-level script while the driver=0Ascripts typically=
 convert the config parameters into switches for a=0A"shellpack". A shellpa=
ck is a pair of benchmark and install scripts=0Athat are all stored in shel=
lpacks/ .=0A=0AMonitors can be optionally configured. A full list is in mon=
itors/=0A. Care should be taken with monitors as there is a possibility tha=
t=0Athey introduce overhead of their own.=A0 Hence, for some performance=0A=
sensitive tests it is preferable to have no monitoring.=0A=0AMany of the te=
sts download external benchmarks. An attempt will be=0Amade to download fro=
m a mirror . To get an idea where the mirror=0Ashould be located, grep for =
MIRROR_LOCATION=3D in shellpacks/.=0A=0AA basic invocation of the suite is=
=0A=0A<pre>=0A$ cp config-global-dhp__pagealloc-performance config=0A$ ./ru=
n-mmtests.sh --no-monitor 3.0-nomonitor=0A$ ./run-mmtests.sh --run-monitor =
3.0-runmonitor=0A</pre>=0A=0AConfiguration=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=0A=0AThe config file used is always called "config". A number of =
other=0Asample configuration files are provided that have a given theme. So=
me=0Aimportant points of variability are;=0A=0AMMTESTS is a list of what te=
sts will be run=0A=0AWEBROOT is the location where a number of tarballs are=
 mirrored. For example,=0A=A0=A0=A0 kernbench tries to download=0A=A0=A0=A0=
 $WEBROOT/kernbench/linux-2.6.30.tar.gz . If this is not available,=0A=A0=
=A0=A0 it is downloaded from the internet. This can add delays in testing=
=0A=A0=A0=A0 and consumes bandwidth so is worth configuring.=0A=0ALINUX_GIT=
 is the location of a git repo of the kernel. At the moment it's only=0A=A0=
=A0=A0 used during report generation=0A=0ASKIP_*PROFILE=0A=A0=A0=A0 These p=
arameters determine what profiling runs are done. Even with=0A=A0=A0=A0 pro=
filing enabled, a non-profile run can be used to ensure that=0A=A0=A0=A0 th=
e profile and non-profile runs are comparable.=0A=0ASWAP_CONFIGURATION=0ASW=
AP_PARTITIONS=0ASWAP_SWAPFILE_SIZEMB=0A=A0=A0=A0 It's possible to use a dif=
ferent swap configuration than what is=0A=A0=A0=A0 provided by default.=0A=
=0ATESTDISK_RAID_PARTITIONS=0ATESTDISK_RAID_DEVICE=0ATESTDISK_RAID_OFFSET=
=0ATESTDISK_RAID_SIZE=0ATESTDISK_RAID_TYPE=0A=A0=A0=A0 If the target machin=
e has partitions suitable for configuring RAID,=0A=A0=A0=A0 they can be spe=
cified here. This RAID partition is then used for=0A=A0=A0=A0 all the tests=
=0A=0ATESTDISK_PARTITION=0A=A0=A0=A0 Use this partition for all tests=0A=0A=
TESTDISK_FILESYSTEM=0ATESTDISK_MKFS_PARAM=0ATESTDISK_MOUNT_ARGS=0A=A0=A0=A0=
 The filesystem, mkfs parameters and mount arguments for the test=0A=A0=A0=
=A0 partitions=0A=0AAvailable tests=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=0A=0ANote the ones that are marked untested. These have been port=
ed from other=0Atest suites but no guarantee they actually work correctly h=
ere. If you want=0Ato run these tests and run into a problem, report a bug.=
=0A=0Akernbench=0A=A0=A0=A0 Builds a kernel 5 times recording the time take=
n to completion.=0A=A0=A0=A0 An average time is stored. This is sensitive t=
o the overall=0A=A0=A0=A0 performance of the system as it hits a number of =
subsystems.=0A=0Amultibuild=0A=A0=A0=A0 Similar to kernbench except it runs=
 a number of kernel compiles=0A=A0=A0=A0 in parallel. Can be useful for str=
essing the system and seeing=0A=A0=A0=A0 how well it deals with simple fork=
-based parallelism.=0A=0Aaim9=0A=A0=A0=A0 Runs a short version of aim9 by d=
efault. Each test runs for 60=0A=A0=A0=A0 seconds. This is a micro-benchmar=
k of a number of VM operations. It's=0A=A0=A0=A0 sensitive to changes in th=
e allocator paths for example.=0A=0Avmr-stream=0A=A0=A0=A0 Runs the STREAM =
benchmark a number of times for varying sizes. An=0A=A0=A0=A0 average is re=
corded. This can be used to measure approximate memory=0A=A0=A0=A0 throughp=
ut or the average cost of a number of basic operations. It is=0A=A0=A0=A0 s=
ensitive to cache layout used for page faults.=0A=0Avmr-cacheeffects (untes=
ted)=0A=A0=A0=A0 Performs linear and random walks on nodes of different siz=
es stored in=0A=A0=A0=A0 a large amount of memory. Sensitive to cache footp=
rint and layout.=0A=0Avmr-createdelete (untested)=0A=A0=A0=A0 A micro-bench=
mark that measures the time taken to create and delete=0A=A0=A0=A0 file or =
anonymous mappings of increasing sizes. Sensitive to changes=0A=A0=A0=A0 in=
 the page fault path performance.=0A=0Aiozone=0A=A0=A0=A0 A basic filesyste=
m benchmark.=0A=0Afsmark=0A=A0=A0=A0 This tests write workloads varying the=
 number of files and directory=0A=A0=A0=A0 depth.=0A=0Ahackbench-*=0A=A0=A0=
=A0 Hackbench is generally a scheduler benchmark but is also sensitive to=
=0A=A0=A0=A0 overhead in the allocators and to a lesser extent the fault pa=
ths.=0A=A0=A0=A0 Can be run for either sockets or pipes.=0A=0Alargecopy=0A=
=A0=A0=A0 This is a simple single-threaded benchmark that downloads a large=
=0A=A0=A0=A0 tar file, expands it a number of times, creates a new tar and=
=0A=A0=A0=A0 expands it again. Each operation is timed and is aimed at shak=
ing=0A=A0=A0=A0 out stall-related bugs when copying large amounts of data=
=0A=0Alargedd=0A=A0=A0=A0 Similar to largecopy except it uses dd instead of=
 cp.=0A=0Alibreofficebuild=0A=A0=A0=A0 This downloads and builds libreoffic=
e. It is a more aggressive=0A=A0=A0=A0 compile-orientated test. This is a v=
ery download-intensive=0A=A0=A0=A0 benchmark and was only created as a repr=
oduction case for=0A=A0=A0=A0 a bug.=0A=0Anas-*=0A=A0=A0=A0 The NAS Paralle=
l Benchmarks for the serial and openmp versions of=0A=A0=A0=A0 the test.=0A=
=0Anetperf-*=0A=A0=A0=A0 Runs the netperf benchmark for *_STREAM on the loc=
al machine.=0A=A0=A0=A0 Sensitive to cache usage and allocator costs. To te=
st for cache line=0A=A0=A0=A0 bouncing, the test can be configured to bind =
to certain processors.=0A=0Apostmark=0A=A0=A0=A0 Run the postmark benchmark=
. Optionally a program can be run in=0A=A0=A0=A0 the background that consum=
es anonymous memory. The background=0A=A0=A0=A0 program is vary rarely need=
ed except when trying to identify=0A=A0=A0=A0 desktop stalls during heavy I=
O.=0A=0Aspeccpu (untested)=0A=A0=A0=A0 SPECcpu, what else can be said. A re=
striction is that you must have=0A=A0=A0=A0 a mirrored copy of the tarball =
as it is not publicly available.=0A=0Aspecjvm (untested)=0A=A0=A0=A0 SPECjv=
m. Same story as speccpu=0A=0Aspecomp (untested)=0A=A0=A0=A0 SPEComp. Same =
story as speccpu=0A=0Asysbench=0A=A0=A0=A0 Runs the complex workload for sy=
sbench backed by postgres. Running=0A=A0=A0=A0 this test requires a signifi=
cant build environment on the test=0A=A0=A0=A0 machine. It can run either r=
ead-only or read/write tests.=0A=0Asimple-writeback=0A=A0=A0=A0 This is a s=
imple writeback test based on dd. It's meant to be=0A=A0=A0=A0 easy to unde=
rstand and quick to run. Useful for measuring page=0A=A0=A0=A0 writeback ch=
anges.=0A=0Altp (untested)=0A=A0=A0=A0 The LTP benchmark. What it is testin=
g depends on exactly which of the=0A=A0=A0=A0 suite is configured to run.=
=0A=0Altp-pounder (untested)=0A=A0=A0=A0 ltp pounder is a non-default test =
that exists in LTP. It's used by=0A=A0=A0=A0 IBM for hardware certification=
 to hammer a machine for a configured=0A=A0=A0=A0 number of hours. Typicall=
y, they expect it to run for 72 hours=0A=A0=A0=A0 without major errors.=A0 =
Useful for testing general VM stability in=0A=A0=A0=A0 high-pressure low-me=
mory situations.=0A=0Astress-highalloc=0A=A0=A0=A0 This test requires that =
the system not have too much memory and=0A=A0=A0=A0 that systemtap is avail=
able. Typically, it's tested with 3GB of=0A=A0=A0=A0 RAM. It builds a numbe=
r of kernels in parallel such that total=0A=A0=A0=A0 memory usage is 1.5 ti=
mes physical memory. When this is running=0A=A0=A0=A0 for 5 minutes, it tri=
es to allocate a large percentage of memory=0A=A0=A0=A0 (e.g. 95%) as huge =
pages recording the latency of each operation as it=0A=A0=A0=A0 goes. It do=
es this twice. It then cancels the kernel compiles, cleans=0A=A0=A0=A0 the =
system and tries to allocate huge pages at rest again. It's a=0A=A0=A0=A0 b=
asic test for fragmentation avoidance and the performance of huge=0A=A0=A0=
=A0 page allocation.=0A=0Axfstests (untested)=0A=A0=A0=A0 This is still at =
prototype level and aimed at running testcase 180=0A=A0=A0=A0 initially to =
reproduce some figures provided by the filesystems people.=0A=0AReporting=
=0A=3D=3D=3D=3D=3D=3D=3D=3D=3D=0A=0AFor reporting, there is a basic compare=
-kernels.sh script. It must be updated=0Awith a list of kernels you want to=
 compare and in what order. It generates a=0Atable for each test, operation=
 and kernel showing the relative performance=0Aof each. The test reporting =
scripts are in subreports/. compare-kernel.sh=0Ashould be run from the path=
 storing the test logs. By default this is=0Awork/log. If you are automatin=
g tests from an external source, work/log is=0Awhat you should be capturing=
 after a set of tests complete.=0A=0AIf monitors are configured such as ftr=
ace, there are additional=0Aprocessing scripts. They can be activated by se=
tting FTRACE_ANALYSERS in=0Acompare-kernels.sh. A basic post-process script=
 is mmtests-duration which=0Asimply reports how long an individual test too=
k and what its CPU usage was.=0A=0AThere are a limited number of graphing s=
cripts included in report/=0A=0ATODO=0A=3D=3D=3D=3D=0A=0Ao Add option to te=
st on filesystem loopback device stored on tmpfs=0Ao Add volanomark=0Ao Cre=
ate config-* set suitable for testing scheduler to isolate situations=0A=A0=
 where the scheduler was the main cause of a regression=0A=0A-- =0AMel Gorm=
an=0ASUSE Labs=0A=0A--=0ATo unsubscribe, send a message with 'unsubscribe l=
inux-mm' in=0Athe body to majordomo@kvack.org.=A0 For more info on Linux MM=
,=0Asee: http://www.linux-mm.org/ .=0AFight unfair telecom internet charges=
 in Canada: sign http://stopthemeter.ca/=0ADon't email: <a href=3Dmailto:"d=
ont@kvack.org"> email@kvack.org </a>=A0=A0=A0 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
