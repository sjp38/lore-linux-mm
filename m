Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id BF99C6B0167
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 14:14:17 -0400 (EDT)
Received: by weys10 with SMTP id s10so2276021wey.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2012 11:14:16 -0700 (PDT)
Message-ID: <50522275.7090709@suse.cz>
Date: Thu, 13 Sep 2012 20:14:13 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: BUG at mm/huge_memory.c:1428!
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Jiri Slaby <jirislaby@gmail.com>

Hi,

I've just get the following BUG with today's -next. It happens every
time I try to update packages.

kernel BUG at mm/huge_memory.c:1428!
invalid opcode: 0000 [#1] SMP
Modules linked in:
CPU 1
Pid: 3087, comm: zypper Tainted: G        W
3.6.0-rc5-next-20120913_64+ #45 Bochs Bochs
RIP: 0010:[<ffffffff81125b04>]  [<ffffffff81125b04>]
split_huge_page+0x6d4/0x830
RSP: 0018:ffff880046223ce8  EFLAGS: 00010296
RAX: 000000000000002f RBX: ffff880043e9d170 RCX: 00000000000000dc
RDX: 000000000000004c RSI: 0000000000000046 RDI: ffffffff81b3c05c
RBP: ffff880046223d58 R08: 000000000000000a R09: 00000000000001b0
R10: 0000000000000000 R11: 00000000000001af R12: 0000000000000000
R13: ffffea0000e60000 R14: 00007f7ff561a000 R15: ffff8800453aa880
FS:  00007f8000069800(0000) GS:ffff880049700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000003611000 CR3: 000000004506e000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process zypper (pid: 3087, threadinfo ffff880046222000, task
ffff880043cf5330)
Stack:
 ffff880047810480 ffff880043ee1980 ffff880047808c40 ffff880043ee19b0
 ffff880046223dc8 0000000000000296 00007f7ff581a000 00000007f7ff561a
 ffffffff8110e8c1 ffffea0000e60000 ffff8800453aa880 ffff88004635abd0
Call Trace:
 [<ffffffff8110e8c1>] ? anon_vma_clone+0x41/0x140
 [<ffffffff8112690f>] __split_huge_page_pmd+0x5f/0xb0
 [<ffffffff811269d5>] split_huge_page_address+0x75/0x80
 [<ffffffff81126a7b>] __vma_adjust_trans_huge+0x9b/0xf0
 [<ffffffff81109064>] vma_adjust+0x564/0x5d0
 [<ffffffff8110929b>] __split_vma.isra.34+0x1cb/0x1e0
 [<ffffffff81109c25>] do_munmap+0xf5/0x400
 [<ffffffff8110ccdb>] sys_mremap+0x2fb/0x520
 [<ffffffff81061ff9>] ? do_page_fault+0x9/0x10
 [<ffffffff8160fa62>] system_call_fastpath+0x16/0x1b
Code: 4e 00 0f 0b f3 90 49 8b 45 00 a9 00 00 80 00 75 f3 e9 de fa ff ff
48 c7 c6 18 58 94 81 48 c7 c7 49 ba 92 81 31 c0 e8 b6 07 4e 00 <0f> 0b
41 8b 55 18 48 c7 c7 f8 57 94 81 31 c0 8b 75 bc 83 c2 01

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
