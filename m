Subject: 2.5.40-mm1 - runalltests - 95.89% pass
From: Paul Larson <plars@linuxtestproject.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 03 Oct 2002 11:11:02 -0500
Message-Id: <1033661465.14606.13.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, lse-tech <lse-tech@lists.sourceforge.net>, ltp-results <ltp-results@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Sorry I havn't had time to look at the -mm kernels in a while, I'll try
to keep up with them better.

Attached are a list of LTP failures for 2.5.40-mm1 with ltp-20020910. 
All are known issues such as the pread/pwrite glibc stuff and the
readv/writev new behaviour (the ltp release next month will address that
for new kernels).  The dio tests failed of course, since the fs was
ext3.  It's my understanding that dio isn't supported in ext3 yet but
please correct me if this is not true.

These results are from an 8-way PIII-700 16GB ram.
No extraneous errors in dmesg other than the well-known sleeping
function illegal context of late.

Thanks,
Paul Larson

tag=nanosleep02 stime=1033594209 dur=1 exit=exited stat=1 core=no cu=0
cs=0
tag=personality01 stime=1033594216 dur=0 exit=exited stat=1 core=no cu=0
cs=0
tag=personality02 stime=1033594216 dur=0 exit=exited stat=1 core=no cu=0
cs=0
tag=pread02 stime=1033594221 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=pwrite02 stime=1033594221 dur=0 exit=exited stat=1 core=no cu=0 cs=1
tag=readv01 stime=1033594221 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=writev01 stime=1033594278 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=dio02 stime=1033595691 dur=1 exit=exited stat=1 core=no cu=1 cs=2
tag=dio03 stime=1033595692 dur=3 exit=exited stat=1 core=no cu=2 cs=1
tag=dio04 stime=1033595695 dur=0 exit=exited stat=1 core=no cu=0 cs=1
tag=dio05 stime=1033595695 dur=2 exit=exited stat=1 core=no cu=7 cs=3
tag=dio08 stime=1033595702 dur=1 exit=exited stat=1 core=no cu=1 cs=2
tag=dio09 stime=1033595703 dur=3 exit=exited stat=1 core=no cu=2 cs=2
tag=dio10 stime=1033595706 dur=400 exit=exited stat=1 core=no cu=122
cs=402
tag=dio11 stime=1033596106 dur=2 exit=exited stat=1 core=no cu=7 cs=4
tag=dio14 stime=1033596161 dur=12 exit=exited stat=1 core=no cu=16 cs=15
tag=dio15 stime=1033596173 dur=29 exit=exited stat=1 core=no cu=13 cs=15
tag=dio16 stime=1033596202 dur=49 exit=exited stat=1 core=no cu=329
cs=94
tag=dio18 stime=1033596286 dur=12 exit=exited stat=1 core=no cu=16 cs=14
tag=dio19 stime=1033596298 dur=21 exit=exited stat=1 core=no cu=13 cs=16
tag=dio20 stime=1033596319 dur=49 exit=exited stat=1 core=no cu=330
cs=70
tag=dio22 stime=1033596395 dur=12 exit=exited stat=1 core=no cu=15 cs=14
tag=dio23 stime=1033596407 dur=21 exit=exited stat=1 core=no cu=13 cs=16
tag=dio24 stime=1033596428 dur=54 exit=exited stat=1 core=no cu=328
cs=77
tag=ar stime=1033596573 dur=6 exit=exited stat=1 core=no cu=40 cs=66
tag=sem02 stime=1033596582 dur=20 exit=exited stat=1 core=no cu=0 cs=0

nanosleep02    1  FAIL  :  Remaining sleep time 4001000 usec doesn't
match with the expected 3999707 usec time
nanosleep02    1  FAIL  :  child process exited abnormally
personality01    3  FAIL  :  returned persona was not expected
personality01    4  FAIL  :  returned persona was not expected
personality01    5  FAIL  :  returned persona was not expected
personality01    6  FAIL  :  returned persona was not expected
personality01    7  FAIL  :  returned persona was not expected
personality01    8  FAIL  :  returned persona was not expected
personality01    9  FAIL  :  returned persona was not expected
personality01   10  FAIL  :  returned persona was not expected
personality01   11  FAIL  :  returned persona was not expected
personality01   12  FAIL  :  returned persona was not expected
personality01   13  FAIL  :  returned persona was not expected
personality02    1  FAIL  :  call failed - errno = 0 - Success
pread02     2  FAIL  :  pread() returned 0, expected -1, errno:22
pwrite02    2  FAIL  :  specified offset is -ve or invalid, unexpected
errno:27, expected:22
readv01     1  FAIL  :  readv() failed with unexpected errno 22
writev01    1  FAIL  :  writev() failed unexpectedly
writev01    0  INFO  :  block 2 FAILED
writev01    2  FAIL  :  writev() failed with unexpected errno 22
writev01    0  INFO  :  block 6 FAILED
FAIL - ar with -v flag failed to print a line for each file
sem02: FAIL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
