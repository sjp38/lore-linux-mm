Subject: 2.5.40-mm2 - runalltests - 98.42% pass
From: Paul Larson <plars@linuxtestproject.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 07 Oct 2002 15:30:43 -0500
Message-Id: <1034022644.15180.43.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, lse-tech <lse-tech@lists.sourceforge.net>, ltp-results <ltp-results@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Much better on mm2, all are known and/or expected failures and the only
two remaining dio failures will be fixed in the next LTP release
(probably coming tomorrow).

Same hardware as before, 8-way PIII-700, 16 GB ram.

There were several sleeping functions called from illegal contexts at
the top of the boot.  If you care to see them, here they are:
Memory: 16328640k/16777216k available (1948k kernel code, 184936k
reserved, 712k data, 128k init, 15597528k highmem)
Total Huge_TLB_Page memory pages allocated 112
Debug: sleeping function called from illegal context at mm/slab.c:1323
Call Trace:
 [<c01171f6>] E __might_sleep_Rsmp_d533bec7+0x46/0x23a778
 [<c01336e1>] E kmem_cache_destroy_Rsmp_df83c692+0x1f1/0xffffffd0
 [<c01337b4>] E kmem_cache_destroy_Rsmp_df83c692+0x2c4/0xffffffd0
 [<c01f19af>] E uart_unregister_port_Rsmp_0279f765+0x1fdf/0xfffffc80
 [<c0133ab6>] E kmem_cache_destroy_Rsmp_df83c692+0x5c6/0xffffffd0
 [<c0133d9b>] E kmem_cache_alloc_Rsmp_75810956+0x3b/0xe0
 [<c0132e8f>] E kmem_cache_create_Rsmp_d1c0b4e6+0x6f/0x6d0
 [<c0119818>] E printk_Rsmp_1b7d4074+0x128/0x140
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f

Security Scaffold v1.0.0 initialized
Dentry-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
Debug: sleeping function called from illegal context at mm/slab.c:1323
Call Trace:
 [<c01171f6>] E __might_sleep_Rsmp_d533bec7+0x46/0x23a778
 [<c01336e1>] E kmem_cache_destroy_Rsmp_df83c692+0x1f1/0xffffffd0
 [<c01337b4>] E kmem_cache_destroy_Rsmp_df83c692+0x2c4/0xffffffd0
 [<c0107b18>] E __read_lock_failed+0x18b4/0x377c
 [<c0133ab6>] E kmem_cache_destroy_Rsmp_df83c692+0x5c6/0xffffffd0
 [<c0133d9b>] E kmem_cache_alloc_Rsmp_75810956+0x3b/0xe0
 [<c015ab4c>] E get_fs_type_Rsmp_009da4a1+0xec/0xfffee5f0
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c015aa8f>] E get_fs_type_Rsmp_009da4a1+0x2f/0xfffee5f0
 [<c014967b>] E get_sb_single_Rsmp_941c6e31+0xbb/0xfffffcc0
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c015a793>] E register_filesystem_Rsmp_90e98ddd+0x43/0x70
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f

Debug: sleeping function called from illegal context at
mm/page_alloc.c:512
Call Trace:
 [<c01171f6>] E __might_sleep_Rsmp_d533bec7+0x46/0x23a778
 [<c0137393>] E __alloc_pages_Rsmp_0c1ddaea+0x23/0x270
 [<c0137605>] E __get_free_pages_Rsmp_4784e424+0x25/0x40
 [<c01337cb>] E kmem_cache_destroy_Rsmp_df83c692+0x2db/0xffffffd0
 [<c0107b18>] E __read_lock_failed+0x18b4/0x377c
 [<c0133ab6>] E kmem_cache_destroy_Rsmp_df83c692+0x5c6/0xffffffd0
 [<c0133d9b>] E kmem_cache_alloc_Rsmp_75810956+0x3b/0xe0
 [<c015ab4c>] E get_fs_type_Rsmp_009da4a1+0xec/0xfffee5f0
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c015aa8f>] E get_fs_type_Rsmp_009da4a1+0x2f/0xfffee5f0
 [<c014967b>] E get_sb_single_Rsmp_941c6e31+0xbb/0xfffffcc0
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c015a793>] E register_filesystem_Rsmp_90e98ddd+0x43/0x70
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f

Debug: sleeping function called from illegal context at
include/linux/rwsem.h:67Call Trace:
 [<c01171f6>] E __might_sleep_Rsmp_d533bec7+0x46/0x23a778
 [<c0148a07>] E bio_init_Rsmp_247a1326+0x127/0xfffff780
 [<c0148da0>] E sget_Rsmp_9f88c676+0x10/0x480
 [<c0149559>] E get_sb_nodev_Rsmp_88323f9c+0x19/0x80
 [<c0149210>] E set_anon_super_Rsmp_f7f0d22d+0x0/0xffff9db0
 [<c0149691>] E get_sb_single_Rsmp_941c6e31+0xd1/0xfffffcc0
 [<c0189f00>] E journal_blocks_per_page_Rsmp_3d546bf6+0x6e90/0xffffb250
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f
 [<c015a793>] E register_filesystem_Rsmp_90e98ddd+0x43/0x70
 [<c0105000>] E Using_Versions+0xc0104fff/0xc0119d0f

Here are the tests that failed:

tag=nanosleep02 stime=1034018305 dur=1 exit=exited stat=1 core=no cu=0 cs=0
tag=personality01 stime=1034018312 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=personality02 stime=1034018312 dur=0 exit=exited stat=1 core=no cu=0 cs=1
tag=pread02 stime=1034018317 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=pwrite02 stime=1034018317 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=readv01 stime=1034018317 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=writev01 stime=1034018374 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=dio04 stime=1034019804 dur=0 exit=exited stat=1 core=no cu=0 cs=0
tag=dio10 stime=1034019816 dur=400 exit=exited stat=1 core=no cu=123 cs=383
tag=sem02 stime=1034020764 dur=20 exit=exited stat=1 core=no cu=0 cs=0

nanosleep02    1  FAIL  :  Remaining sleep time 4001000 usec doesn't match with
the expected 3999360 usec time
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
pwrite02    2  FAIL  :  specified offset is -ve or invalid, unexpected errno:27, expected:22
readv01     1  FAIL  :  readv() failed with unexpected errno 22
writev01    1  FAIL  :  writev() failed unexpectedly
writev01    0  INFO  :  block 2 FAILED
writev01    2  FAIL  :  writev() failed with unexpected errno 22
writev01    0  INFO  :  block 6 FAILED
sem02: FAIL
pan reported FAIL

ver_linux output:
Red Hat Linux release 7.3 (Valhalla)
Linux cobra.ltc.austin.ibm.com 2.5.40 #0 SMP Mon Oct 7 08:40:20 CDT 2002 i686 unknown

Gnu C                  2.96
Gnu make               3.79.1
util-linux             2.11n
mount                  2.11n
modutils               2.4.14
e2fsprogs              1.27
reiserfsprogs          3.x.0j
pcmcia-cs              3.1.22
PPP                    2.4.1
isdn4k-utils           3.1pre1
Linux C Library        2.2.5
Dynamic linker (ldd)   2.2.5
Procps                 2.0.7
Net-tools              1.60
Console-tools          0.3.3
Sh-utils               2.0.11
Modules Loaded

free -m reports:
             total       used       free     shared    buffers     cached
Mem:         15947        672      15274          0         61         63
-/+ buffers/cache:        547      15399
Swap:        15350          0      15350

/proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
bogomips        : 1376.25

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
bogomips        : 1396.73

processor       : 2
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
bogomips        : 1396.73

processor       : 3
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
bogomips        : 1396.73

processor       : 4
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
bogomips        : 1396.73

processor       : 5
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
bogomips        : 1396.73

processor       : 6
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 mmx fxsr sse
bogomips        : 1396.73

processor       : 7
vendor_id       : GenuineIntel
cpu family      : 6
model           : 10
model name      : Pentium III (Cascades)
stepping        : 1
cpu MHz         : 700.030
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 mmx fxsr sse
bogomips        : 1396.73

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
