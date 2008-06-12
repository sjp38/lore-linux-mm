Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5C8iMht014440
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:14:22 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5C8heou872486
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:13:40 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5C8iMWW018025
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:14:22 +0530
Message-ID: <4850E1E5.90806@linux.vnet.ibm.com>
Date: Thu, 12 Jun 2008 14:14:21 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [BUG] 2.6.26-rc5-mm3 kernel BUG at mm/filemap.c:575!
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
In-Reply-To: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

2.6.26-rc5-mm3 kernel panics while booting up on the x86_64
machine. Sorry the console is bit overwritten for the first few lines.

------------[ cut here ]------------
ot fs
no fstab.kernel BUG at mm/filemap.c:575!
sys, mounting ininvalid opcode: 0000 [1] ternal defaultsSMP 
Switching to ne
w root and runnilast sysfs file: /sys/block/dm-3/removable
ng init.
unmounCPU 3 ting old /dev
u
nmounting old /pModules linked in:roc
unmounting 
old /sys
Pid: 1, comm: init Not tainted 2.6.26-rc5-mm3-autotest #1
RIP: 0010:[<ffffffff80268155>]  [<ffffffff80268155>] unlock_page+0xf/0x26
RSP: 0018:ffff81003f9e1dc8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe20000f63080 RCX: 0000000000000036
RDX: 0000000000000000 RSI: ffffe20000f63080 RDI: ffffe20000f63080
RBP: 0000000000000000 R08: ffff81003f9a5727 R09: ffffc10000200200
R10: ffffc10000100100 R11: 000000000000000e R12: 0000000000000000
R13: 0000000000000000 R14: ffff81003f47aed8 R15: 0000000000000000
FS:  000000000066d870(0063) GS:ffff81003f99fa80(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000065afa0 CR3: 000000003d580000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process init (pid: 1, threadinfo ffff81003f9e0000, task ffff81003f9d8000)
Stack:  ffffe20000f63080 ffffffff80270d9c 0000000000000000 ffffffffffffffff
 000000000000000e 0000000000000000 ffffe20000f63080 ffffe20000f630c0
 ffffe20000f63100 ffffe20000f63140 ffffe20000f63180 ffffe20000f631c0
Call Trace:
 [<ffffffff80270d9c>] truncate_inode_pages_range+0xc5/0x305
 [<ffffffff802a7177>] generic_delete_inode+0xc9/0x133
 [<ffffffff8029e3cd>] do_unlinkat+0xf0/0x160
 [<ffffffff8020bd0b>] system_call_after_swapgs+0x7b/0x80


Code: 00 00 48 85 c0 74 0b 48 8b 40 10 48 85 c0 74 02 ff d0 e8 75 ec 32 00 41 5b 31 c0 c3 53 48 89 fb f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 56 f5 ff ff 48 89 de 48 89 c7 31 d2 5b e9 47 be 
RIP  [<ffffffff80268155>] unlock_page+0xf/0x26
 RSP <ffff81003f9e1dc8>
---[ end trace 27b1d01b03af7c12 ]---
Kernel panic - not syncing: Attempted to kill init!
Pid: 1, comm: init Tainted: G      D   2.6.26-rc5-mm3-autotest #1

Call Trace:
 [<ffffffff80232d87>] panic+0x86/0x144
 [<ffffffff80233a09>] printk+0x4e/0x56
 [<ffffffff80235740>] do_exit+0x71/0x67c
 [<ffffffff80598691>] oops_begin+0x0/0x8c
 [<ffffffff8020dbc0>] do_invalid_op+0x87/0x91
 [<ffffffff80268155>] unlock_page+0xf/0x26
 [<ffffffff805982d9>] error_exit+0x0/0x51
 [<ffffffff80268155>] unlock_page+0xf/0x26
 [<ffffffff80270d9c>] truncate_inode_pages_range+0xc5/0x305
 [<ffffffff802a7177>] generic_delete_inode+0xc9/0x133
 [<ffffffff8029e3cd>] do_unlinkat+0xf0/0x160
 [<ffffffff8020bd0b>] system_call_after_swapgs+0x7b/0x80


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
