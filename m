Received: from raistlin.arm.linux.org.uk (root@raistlin [192.168.0.3])
	by caramon.arm.linux.org.uk (8.9.3/8.9.3) with ESMTP id RAA00914
	for <linux-mm@kvack.org>; Fri, 28 Apr 2000 17:47:20 +0100
From: Russell King <rmk@arm.linux.org.uk>
Received: (from rmk@localhost)
	by raistlin.arm.linux.org.uk (8.7.4/8.7.3) id RAA01548
	for linux-mm@kvack.org; Fri, 28 Apr 2000 17:41:44 +0100
Message-Id: <200004281641.RAA01548@raistlin.arm.linux.org.uk>
Subject: Re: Memory Test Suite v0.0.2
Date: Fri, 28 Apr 2000 17:41:43 +0100 (BST)
In-Reply-To: <yttitx3cgww.fsf@vexeta.dc.fi.udc.es> from "Juan J. Quintela" at Apr 28, 2000 12:34:07 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Juan J. Quintela writes:
> Memory test suite v0.0.2

I've just been trying this package out on a NetWinder, and I've just
deadlocked 2.3.99-pre6 - I've got 0KB memory free!  I changed misc_lib.h
to reflect the amount of RAM I have in this machine (32MB).

I ran ./mmap002 twice - the first time it got a bus error.  The second
time it didn't even make it to the first msync() call.

Here is the mem and state info.  If there's anything other info you want,
let me know - its extremely easy to cause this.

<6>SysRq: Show Memory
Mem-info:
Free pages:           0kB (     0kB HighMem)
( Free: 0, lru_cache: 6495 (64 128 192) )
  DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB = 0kB)
  Normal: = 0kB)
  HighMem: = 0kB)
Swap cache: add 14628, delete 14453, find 4642/14916
Free swap:        59724kB
8192 pages of RAM
195 free pages
684 reserved pages
7847 pages shared
175 pages swap cached
0 page tables cached
Buffer memory:      120kB

<6>SysRq: Show State
                         free                        sibling
  task             PC    stack   pid father child younger older
init      D C003EC8C    16     1      0   623  (NOTLB)        
   sig: 0 0000000000000000 0000000000000000 : X
kswapd    D C003EC8C     0     2      1        (L-TLB)       3
   sig: 0 0000000000000000 ffffffffffffffff : X
kflushd   S C003EC8C     0     3      1        (L-TLB)       4     2
   sig: 0 0000000000000000 ffffffffffffffff : X
kupdate   S C003EC8C    12     4      1        (L-TLB)     127     3
   sig: 0 0000000000000000 fffffffffff9ffff : X
kerneld   S C003EC8C     0   127      1        (NOTLB)     227     4
   sig: 0 0000000000000000 0000000000000000 : X
pump      S C003EC8C     0   227      1        (NOTLB)     324   127
   sig: 0 0000000000000000 0000000000000000 : X
portmap   S C003EC8C     0   324      1        (NOTLB)     376   227
   sig: 0 0000000000000000 0000000000000000 : X
syslogd   D C003EC8C  1552   376      1        (NOTLB)     386   324
   sig: 1 0000000000002000 0000000000000000 : X
klogd     D C003EC8C  1356   386      1        (NOTLB)     401   376
   sig: 0 0000000000000000 0000000000000000 : X
atd       S C003EC8C     0   401      1        (NOTLB)     416   386
   sig: 0 0000000000000000 0000000000010000 : X
crond     D C003EC8C     0   416      1        (NOTLB)     431   401
   sig: 0 0000000000000000 0000000000010000 : X
inetd     S C003EC8C     4   431      1        (NOTLB)     440   416
   sig: 0 0000000000000000 0000000000000000 : X
sshd      S C003EC8C     0   440      1        (NOTLB)     455   431
   sig: 0 0000000000000000 0000000000000000 : X
xntpd     D C003EC8C     0   455      1        (NOTLB)     470   440
   sig: 1 0000000000002000 0000000000000000 : X
lpd       S C003EC8C     0   470      1        (NOTLB)     485   455
   sig: 0 0000000000000000 0000000000000000 : X
rpc.mountd  D C003EC8C     0   485      1        (NOTLB)     495   470
   sig: 1 0000000000002000 0000000000000000 : X
rpc.nfsd  D C003EC8C     0   495      1        (NOTLB)     535   485
   sig: 1 0000000000002000 0000000000000000 : X
automount  S C003EC8C     0   535      1        (NOTLB)     537   495
   sig: 0 0000000000000000 0000000000000000 : X
automount  S C003EC8C     0   537      1        (NOTLB)     565   535
   sig: 0 0000000000000000 0000000000000000 : X
sendmail  D C003EC8C     0   565      1        (NOTLB)     581   537
   sig: 0 0000000000000000 0000000000000000 : X
gpm       S C003EC8C     0   581      1        (NOTLB)     606   565
   sig: 0 0000000000000000 0000000000000000 : X
xfs       D C003EC8C  3044   606      1        (NOTLB)     618   581
   sig: 0 0000000000000000 0000000000000000 : X
login     S C003EC8C   180   618      1   626  (NOTLB)     619   606
   sig: 0 0000000000000000 0000000000000000 : X
login     S C003EC8C     0   619      1   647  (NOTLB)     620   618
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  D C003EC8C     0   620      1        (NOTLB)     621   619
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S C003EC8C     0   621      1        (NOTLB)     622   620
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S C003EC8C     0   622      1        (NOTLB)     623   621
   sig: 0 0000000000000000 0000000000000000 : X
mingetty  S C003EC8C   480   623      1        (NOTLB)           622
   sig: 0 0000000000000000 0000000000000000 : X
bash      S C003EC8C   968   626    618   666  (NOTLB)        
   sig: 0 0000000000000000 0000000000010000 : X
bash      S C003EC8C     0   647    619   661  (NOTLB)        
   sig: 0 0000000000000000 0000000000010000 : X
top       D C003EC8C     8   661    647        (NOTLB)        
   sig: 0 0000000000000000 0000000000000000 : X
strace    S C003EC8C     0   666    626   667  (NOTLB)        
   sig: 0 0000000000000000 0000000000000000 : X
mmap002   D C003EC8C     0   667    666        (NOTLB)        
   sig: 0 0000000000000000 0000000000000000 : X


   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | |   http://www.arm.linux.org.uk/~rmk/aboutme.html    /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
