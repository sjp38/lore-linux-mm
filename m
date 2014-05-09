Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 188AB6B0038
	for <linux-mm@kvack.org>; Fri,  9 May 2014 05:54:37 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so4248377pab.0
        for <linux-mm@kvack.org>; Fri, 09 May 2014 02:54:36 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id hu10si1983397pbc.315.2014.05.09.02.54.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 09 May 2014 02:54:35 -0700 (PDT)
Message-ID: <536CA54A.3060707@huawei.com>
Date: Fri, 9 May 2014 17:52:10 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: kmemcheck: got WARNING when dynamicly adjust /proc/sys/kernel/kmemcheck
 to 0/1
References: <536C8A75.4080401@huawei.com>
In-Reply-To: <536C8A75.4080401@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vegard Nossum <vegard.nossum@oracle.com>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Vegard Nossum <vegard.nossum@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2014/5/9 15:57, Xishi Qiu wrote:

> OS boot with kmemcheck=0, then set 1, do something, set 0, do something, set 1...
> then I got the WARNING log. Does kmemcheck support dynamicly adjust?
> 
> Thanks,
> Xishi Qiu
> 
> [   20.200305] igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
> [   20.208652] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   20.216504] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [   22.647385] auditd (3116): /proc/3116/oom_adj is deprecated, please use /proc/3116/oom_score_adj instead.
> [   24.845214] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
> [   30.434764] eth0: no IPv6 routers present
> [  340.154608] NOHZ: local_softirq_pending 01
> [  340.154639] WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff88083f43a550)
> [  340.154644] c000000002000000000000000000000080ff5d0100c9ffff400ed34e0888ffff
> [  340.154667]  u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u
> [  340.154687]                                  ^
> [  340.154690]
> [  340.154694] Pid: 3, comm: ksoftirqd/0 Tainted: G         C   3.4.24-qiuxishi.19-0.1-default+ #2 Huawei Technologies Co., Ltd. Tecal RH2285 V2-24S/BC11SRSC1
> [  340.154702] RIP: 0010:[<ffffffff81217d72>]  [<ffffffff81217d72>] d_namespace_path+0x132/0x270
> [  340.154714] RSP: 0018:ffff8808515a1c88  EFLAGS: 00010202
> [  340.154718] RAX: ffff88083f43a540 RBX: ffff880852e718f3 RCX: 0000000000000001
> [  340.154721] RDX: ffff8808515a1d28 RSI: 0000000000000000 RDI: ffff881053855a60
> [  340.154725] RBP: ffff8808515a1ce8 R08: ffff8808515a1c50 R09: ffff880852e75800
> [  340.154728] R10: 00000000000156f0 R11: 0000000000000000 R12: 0000000000000001
> [  340.154731] R13: 0000000000000100 R14: ffff880852e71510 R15: ffff880852e71800
> [  340.154736] FS:  0000000000000000(0000) GS:ffff88085f600000(0000) knlGS:0000000000000000
> [  340.154740] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  340.154743] CR2: ffff880852e71570 CR3: 00000008513f2000 CR4: 00000000000407f0
> [  340.154746] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  340.154750] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
> [  340.154753]  [<ffffffff81217f35>] aa_path_name+0x85/0x180
> [  340.154758]  [<ffffffff812187d6>] apparmor_bprm_set_creds+0x126/0x520
> [  340.154763]  [<ffffffff811f60ae>] security_bprm_set_creds+0xe/0x10
> [  340.154771]  [<ffffffff81170d65>] prepare_binprm+0xa5/0x100
> [  340.154777]  [<ffffffff811716c2>] do_execve_common+0x232/0x430
> [  340.154781]  [<ffffffff8117194a>] do_execve+0x3a/0x40
> [  340.154785]  [<ffffffff8100abb9>] sys_execve+0x49/0x70
> [  340.154793]  [<ffffffff814764bc>] stub_execve+0x6c/0xc0
> [  340.154801]  [<ffffffffffffffff>] 0xffffffffffffffff
> [  340.154813] WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff88083f43a570)
> [  340.154817] 746f70000300000078a5433f0888fffff86d433f0888ffff746f700000730000
> [  340.154839]  u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u
> [  340.154858]                                  ^
> [  340.154861]
> [  340.154864] Pid: 3, comm: ksoftirqd/0 Tainted: G         C   3.4.24-qiuxishi.19-0.1-default+ #2 Huawei Technologies Co., Ltd. Tecal RH2285 V2-24S/BC11SRSC1
> [  340.154871] RIP: 0010:[<ffffffff811691f4>]  [<ffffffff811691f4>] rw_verify_area+0x24/0x100
> [  340.154880] RSP: 0018:ffff8808515a1dc8  EFLAGS: 00010202
> [  340.154883] RAX: ffff88083f43a540 RBX: 0000000000000080 RCX: 0000000000000080
> [  340.154887] RDX: ffff8808515a1e30 RSI: ffff880852e71500 RDI: 0000000000000000
> [  340.154890] RBP: ffff8808515a1de8 R08: ffff880852e73200 R09: ffff88085f004900
> [  340.154894] R10: ffff880852e72600 R11: 0000000000000000 R12: ffff880852e71500
> [  340.154897] R13: 0000000000000000 R14: ffff880852e73200 R15: 0000000000000001
> [  340.154901] FS:  0000000000000000(0000) GS:ffff88085f600000(0000) knlGS:0000000000000000
> [  340.154905] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  340.154908] CR2: ffff880852e71570 CR3: 00000008513f2000 CR4: 00000000000407f0
> [  340.154911] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  340.154914] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
> [  340.154917]  [<ffffffff811698f4>] vfs_read+0xa4/0x130
> [  340.154922]  [<ffffffff81170ca4>] kernel_read+0x44/0x60
> [  340.154926]  [<ffffffff81170d90>] prepare_binprm+0xd0/0x100
> [  340.154931]  [<ffffffff811716c2>] do_execve_common+0x232/0x430
> [  340.154935]  [<ffffffff8117194a>] do_execve+0x3a/0x40
> [  340.154939]  [<ffffffff8100abb9>] sys_execve+0x49/0x70
> [  340.154944]  [<ffffffff814764bc>] stub_execve+0x6c/0xc0
> [  340.154950]  [<ffffffffffffffff>] 0xffffffffffffffff
> [  340.154955] WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (ffff88083f43a540)
> [  340.154959] c000000002000000000000000000000080ff5d0100c9ffff400ed34e0888ffff
> [  340.154981]  u u u u u u u u u u u u u u u u i i i i i i i i u u u u u u u u
> [  340.155000]  ^
> 
> 

Another problem, does there some way will initialize the shadow?
I only find the object has been initialized.

kmemcheck_slab_alloc()
	...
	/*
	 * Has already been memset(), which initializes the shadow for us
	 * as well.
	 */
	if (gfpflags & __GFP_ZERO)
		return;  ----> add kmemcheck_mark_initialized() ?
	...

slab:
	slab_alloc()
	...
	if (likely(objp))
		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);

	if (unlikely((flags & __GFP_ZERO) && objp))
		memset(objp, 0, cachep->object_size);

	return objp;

slub:
	slab_alloc_node()
	...
	if (unlikely(gfpflags & __GFP_ZERO) && object)
		memset(object, 0, s->object_size);

	slab_post_alloc_hook(s, gfpflags, object);

	return object;

The shadow memory which used for slab/slub is called from kmemcheck_alloc_shadow(),
and it will initialized *only* in kmemcheck_slab_alloc(), right?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
