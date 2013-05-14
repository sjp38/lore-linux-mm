Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id DF3CD6B007B
	for <linux-mm@kvack.org>; Mon, 13 May 2013 23:35:40 -0400 (EDT)
Message-ID: <5191B101.1070000@redhat.com>
Date: Tue, 14 May 2013 11:35:29 +0800
From: Lingzhu Xiang <lxiang@redhat.com>
MIME-Version: 1.0
Subject: Re: 3.9.0: panic during boot - kernel BUG at include/linux/gfp.h:323!
References: <22600323.7586117.1367826906910.JavaMail.root@redhat.com>
In-Reply-To: <22600323.7586117.1367826906910.JavaMail.root@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/06/2013 03:55 PM, CAI Qian wrote:
> [    0.928031] ------------[ cut here ]------------
> [    0.934231] kernel BUG at include/linux/gfp.h:323!
> [    0.940581] invalid opcode: 0000 [#1] SMP
> [    0.945982] Modules linked in:
> [    0.950048] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.9.0+ #1
> [    0.957877] Hardware name: ProLiant BL465c G7, BIOS A19 12/10/2011
> [    1.066325] task: ffff880234608000 ti: ffff880234602000 task.ti: ffff880234602000
> [    1.076603] RIP: 0010:[<ffffffff8117495d>]  [<ffffffff8117495d>] new_slab+0x2ad/0x340
> [    1.087043] RSP: 0000:ffff880234603bf8  EFLAGS: 00010246
> [    1.094067] RAX: 0000000000000000 RBX: ffff880237404b40 RCX: 00000000000000d0
> [    1.103565] RDX: 0000000000000001 RSI: 0000000000000003 RDI: 00000000002052d0
> [    1.113071] RBP: ffff880234603c28 R08: 0000000000000000 R09: 0000000000000001
> [    1.122461] R10: 0000000000000001 R11: ffffffff812e3aa8 R12: 0000000000000001
> [    1.132025] R13: ffff8802378161c0 R14: 0000000000030027 R15: 00000000000040d0
> [    1.141532] FS:  0000000000000000(0000) GS:ffff880237800000(0000) knlGS:0000000000000000
> [    1.152306] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [    1.160004] CR2: ffff88043fdff000 CR3: 00000000018d5000 CR4: 00000000000007f0
> [    1.169519] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    1.179009] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [    1.188383] Stack:
> [    1.191088]  ffff880234603c28 0000000000000001 00000000000000d0 ffff8802378161c0
> [    1.200825]  ffff880237404b40 ffff880237404b40 ffff880234603d28 ffffffff815edba1
> [    1.21ea0008dd0300 ffff880237816140 0000000000000000 ffff88023740e1c0
> [    1.519233] Call Trace:
> [    1.522392]  [<ffffffff815edba1>] __slab_alloc+0x330/0x4f2
> [    1.529758]  [<ffffffff812e3aa8>] ? alloc_cpumask_var_node+0x28/0x90
> [    1.538126]  [<ffffffff81a0bd6e>] ? wq_numa_init+0xc8/0x1be
> [    1.545642]  [<ffffffff81174b25>] kmem_cache_alloc_node_trace+0xa5/0x200
> [    1.554480]  [<ffffffff812e8>] ? alloc_cpumask_var_node+0x28/0x90
> [    1.662913]  [<ffffffff812e3aa8>] alloc_cpumask_var_node+0x28/0x90
> [    1.671224]  [<ffffffff81a0bdb3>] wq_numa_init+0x10d/0x1be
> [    1.678483]  [<ffffffff81a0be64>] ? wq_numa_init+0x1be/0x1be
> [    1.686085]  [<ffffffff81a0bec8>] init_workqueues+0x64/0x341
> [    1.693537]  [<ffffffff8107b687>] ? smpboot_register_percpu_thread+0xc7/0xf0
> [    1.702970]  [<ffffffff81a0ac4a>] ? ftrace_define_fields_softirq+0x32/0x32
> [    1.712039]  [<ffffffff81a0be64>] ? wq_numa_init+0x1be/0x1be
> [    1.719683]  [<ffffffff810002ea>] do_one_initcall+0xea/0x1a0
> [    1.727162]  [<ffffffff819f1f31>] kernel_init_freeable+0xb7/0x1ec
> [    1.735316]  [<ffffffff815d50d0>] ? rest_init+0x80/0x80
> [    1.742121]  [<ffffffff815d50de>] kernel_init+0xe/0xf0
> [    1.748950]  [<ffffffff815ff89c>] ret_from_fork+0x7c/0xb0
> [    1.756443]  [<ffffffff815d50d0>] ? rest_init+0x80/0x80
> [    1.763250] Code: 45  84 ac 00 00 00 f0 41 80 4d 00 40 e9 f6 fe ff ff 66 0f 1f 84 00 00 00 00 00 e8 eb 4b ff ff 49 89 c5 e9 05 fe ff ff <0f> 0b 4c 8b 73 38 44 89 ff 81 cf 00 00 20 00 4c 89 f6 48 c1 ee
> [    2.187072] RIP  [<ffffffff8117495d>] new_slab+0x2ad/0x340
> [    2.194238]  RSP <ffff880234603bf8>
> [    2.198982] ---[ end trace 43bf8bb0334e5135 ]---
> [    2.205097] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

This is always reproducible on two machines. Each of the two has 4 
possible numa nodes and 2 actually online ones.

wq_numa_init is new addition in 3.10-rc1. I suspect that for_each_node() 
in wq_numa_init has accessed offline numa nodes.

Two more tests show:

- Once booted with numa=off, this panic no longer happens.
- After sed -i s/for_each_node/for_each_online_node/ kernel/workqueue.c,
   panic no longer happens.


Lingzhu Xiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
