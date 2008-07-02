Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m626Pdux019012
	for <linux-mm@kvack.org>; Wed, 2 Jul 2008 11:55:39 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m626OPMA888854
	for <linux-mm@kvack.org>; Wed, 2 Jul 2008 11:54:25 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m626Pc9N028394
	for <linux-mm@kvack.org>; Wed, 2 Jul 2008 11:55:38 +0530
Message-ID: <486B1F60.1030608@linux.vnet.ibm.com>
Date: Wed, 02 Jul 2008 11:55:36 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [BUG] 2.6.26-rc8-git2 - kernel BUG at mm/page_alloc.c:585
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel list <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linuxppc-dev@ozlabs.org, kernel-testers@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

when running kernbench on powerpc box booted with the 2.6.26-rc8-git2
kernel the machine drops to xmon with the kernel BUG

kernel BUG at mm/page_alloc.c:585!
cpu 0x0: Vector: 700 (Program Check) at [c0000000c389ed50]
    pc: c0000000000e22ec: .__rmqueue+0x178/0x25c
    lr: c0000000000e22ec: .__rmqueue+0x178/0x25c
    sp: c0000000c389efd0
   msr: 8000000000029032
  current = 0xc0000000f6e0e790
  paca    = 0xc000000000873480
    pid   = 3421, comm = tar
kernel BUG at mm/page_alloc.c:585!
enter ? for help
[c0000000c389efd0] c0000000000e22d0 .__rmqueue+0x15c/0x25c (unreliable)
[c0000000c389f0a0] c0000000000e2438 .rmqueue_bulk+0x68/0xf0
[c0000000c389f170] c0000000000e43cc .get_page_from_freelist+0x2d0/0x848
[c0000000c389f2b0] c0000000000e4abc .__alloc_pages_internal+0x12c/0x494
[c0000000c389f3c0] c0000000000e4e6c .__alloc_pages+0x1c/0x30
[c0000000c389f440] c0000000001107d8 .kmem_getpages+0x90/0x198
[c0000000c389f4e0] c000000000111200 .fallback_alloc+0x190/0x26c
[c0000000c389f5b0] c000000000111478 .____cache_alloc_node+0x19c/0x1d0
[c0000000c389f660] c000000000111e90 .kmem_cache_alloc+0x150/0x1f8
[c0000000c389f710] d00000000019fb50 .ext3_alloc_inode+0x2c/0x74 [ext3]
[c0000000c389f790] c00000000013725c .alloc_inode+0x58/0x278
[c0000000c389f830] c0000000001374b4 .new_inode+0x38/0xd4
[c0000000c389f8d0] d000000000193930 .ext3_new_inode+0x90/0xc64 [ext3]
[c0000000c389f9f0] d00000000019dc28 .ext3_create+0xc4/0x16c [ext3]
[c0000000c389fab0] c000000000127944 .vfs_create+0x12c/0x1d4
[c0000000c389fb60] c00000000012b54c .do_filp_open+0x210/0x8b4
[c0000000c389fd00] c0000000001191f8 .do_sys_open+0x80/0x144
[c0000000c389fdb0] c00000000015f5d8 .compat_sys_open+0x2c/0x44
[c0000000c389fe30] c0000000000086dc syscall_exit+0x0/0x40
--- Exception: c00 (System Call) at 000000000ff0e6d4
SP (ffd3f5a0) is in userspace
0:mon> r
R00 = 00000000f0008d00   R16 = 0000000000000001
R01 = c0000000c389efd0   R17 = 0000000000000044
R02 = c0000000007e74e0   R18 = 0000000000000001
R03 = 0000000000000001   R19 = c00000010ffff828
R04 = f000000000069000   R20 = c00000010ffff800
R05 = 0000000000000003   R21 = c0000001ffff5700
R06 = 0000000000000008   R22 = 0000000000000000
R07 = 0000000000000000   R23 = 0000000000000001
R08 = 0000000000001180   R24 = 0000000000000007
R09 = 00000000f0008cff   R25 = 0000000000000007
R10 = c0000001ffff5700   R26 = 0000000000000080
R11 = c000000000885df8   R27 = c0000001ffff5e28
R12 = c000000010010080   R28 = f000000000066000
R13 = c000000000873480   R29 = f000000000069000
R14 = 0000000000000001   R30 = c000000000791ce0
R15 = 0000000000000001   R31 = c0000000c389efd0
pc  = c0000000000e22ec .__rmqueue+0x178/0x25c
lr  = c0000000000e22ec .__rmqueue+0x178/0x25c
msr = 8000000000029032   cr  = 24000442
ctr = 0000000000000003   xer = 0000000020000000   trap =  700
0:mon> u
SLB contents of cpu 0
00 c000000008000000 40004f7ca3000510  1T  ESID=   c00000  VSID=       4f7ca3 LLP:110 
01 d000000008000000 4000eb71b0000510  1T  ESID=   d00000  VSID=       eb71b0 LLP:110 
11 0000000008000000 000020b2b24a4d90 256M ESID=        0  VSID=    20b2b24a4 LLP:110 
12 00000000f8000000 00002bea2a039d90 256M ESID=        f  VSID=    2bea2a039 LLP:110 
13 0000000048000000 000023b06bd10d90 256M ESID=        4  VSID=    23b06bd10 LLP:110 
14 0000000018000000 0000217220abfd90 256M ESID=        1  VSID=    217220abf LLP:110 
38 f000000008000000 4000235bcc000500  1T  ESID=   f00000  VSID=       235bcc LLP:100 

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
