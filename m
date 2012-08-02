Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 899076B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:13:07 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:13:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
In-Reply-To: <501A3F1E.4060307@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020912340.23049@router.home>
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=------------010205070903070806020800
Content-ID: <alpine.DEB.2.00.1208020912341.23049@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--------------010205070903070806020800
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1208020912342.23049@router.home>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> After applying v8, and proceeding with cache deletion + later insertion
> as I've previously laid down, I can still see the bug I mentioned here.
>
> I am attaching the backtrace I've got with SLUB_DEBUG_ON. My first guess
> based on it would be a double free somewhere.

This looks like you are passing an invalid pointer to kfree.

--------------010205070903070806020800
Content-Type: TEXT/PLAIN; CHARSET=UTF-8; NAME=serial
Content-ID: <alpine.DEB.2.00.1208020912343.23049@router.home>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=serial

containers2 login: [   28.399559] general protection fault: 0000 [#1] SMP 

[   28.400532] CPU 0 

[   28.400532] Modules linked in:

[   28.400532] 

[   28.400532] Pid: 1143, comm: mkdir Not tainted 3.5.0-rc1+ #387 Bochs Bochs

[   28.400532] RIP: 0010:[<ffffffff8112fed3>]  [<ffffffff8112fed3>] virt_to_head_page+0x1e/0x2c

[   28.400532] RSP: 0018:ffff8800378a1db8  EFLAGS: 00010203

[   28.400532] RAX: 01ad998dadadad80 RBX: 6b6b6b6b6b6b6b6b RCX: ffff88003f388730

[   28.400532] RDX: ffffea0000000000 RSI: ffff88003f388708 RDI: 6b6b6b6b6b6b6b6b

[   28.400532] RBP: ffff8800378a1db8 R08: dead000000200200 R09: 2b508c806051e290

[   28.400532] R10: 0000000000000020 R11: ffff88003ea13b68 R12: ffff880037a8db38

[   28.400532] R13: ffffffff81110fef R14: ffff880037a50fd8 R15: 0000000000000000

[   28.400532] FS:  00007fe7352057c0(0000) GS:ffff88003ea00000(0000) knlGS:0000000000000000

[   28.400532] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b

[   28.400532] CR2: 00007f5004de9000 CR3: 000000003b6db000 CR4: 00000000000006f0

[   28.400532] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

[   28.400532] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

[   28.400532] Process mkdir (pid: 1143, threadinfo ffff8800378a0000, task ffff88003f388000)

[   28.400532] Stack:

[   28.400532]  ffff8800378a1de8 ffffffff81132b59 ffff880037a8dad0 ffff880037a8db38

[   28.400532]  0000000000000004 ffff880037a50fd8 ffff8800378a1e08 ffffffff81110fef

[   28.400532]  ffffc90000861000 ffffc90000184000 ffff8800378a1e28 ffffffff8113ee33

[   28.400532] Call Trace:

[   28.400532]  [<ffffffff81132b59>] kfree+0x4c/0xfb

[   28.400532]  [<ffffffff81110fef>] kmem_cache_destroy+0x53/0xa7

[   28.400532]  [<ffffffff8113ee33>] mybug+0x4a/0xa3

[   28.400532]  [<ffffffff814fa71c>] mem_cgroup_create+0x2db/0x423

[   28.400532]  [<ffffffff810a6f8e>] cgroup_mkdir+0xd1/0x37c

[   28.400532]  [<ffffffff8114df09>] vfs_mkdir+0x7e/0xcd

[   28.400532]  [<ffffffff8114f848>] sys_mkdirat+0x6f/0xae

[   28.400532]  [<ffffffff8114f8a0>] sys_mkdir+0x19/0x1b

[   28.400532]  [<ffffffff81523369>] system_call_fastpath+0x16/0x1b

[   28.400532] Code: f9 03 48 89 e5 48 83 e1 f8 f3 aa 5d c3 55 48 89 e5 e8 1e 78 f0 ff 48 c1 e8 0c 48 ba 00 00 00 00 00 ea ff ff 48 c1 e0 06 48 01 d0 <48> 8b 10 80 e6 80 74 04 48 8b 40 30 5d c3 55 48 89 e5 53 50 66 

[   28.400532] RIP  [<ffffffff8112fed3>] virt_to_head_page+0x1e/0x2c

[   28.400532]  RSP <ffff8800378a1db8>

[   28.440928] ---[ end trace 75e62f10600e2a23 ]---


--------------010205070903070806020800--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
