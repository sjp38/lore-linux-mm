Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5175B6B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 16:23:58 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so856514pdj.3
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 13:23:57 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id xk2si30362421pab.332.2014.02.05.13.23.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 13:23:57 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id w10so856744pde.7
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 13:23:56 -0800 (PST)
Date: Wed, 5 Feb 2014 13:23:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Thread overran stack, or stack corrupted on 3.13.0
In-Reply-To: <20140205151817.GA28502@paralelels.com>
Message-ID: <alpine.DEB.2.02.1402051323100.14325@chino.kir.corp.google.com>
References: <20140205151817.GA28502@paralelels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Vagin <avagin@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 5 Feb 2014, Andrew Vagin wrote:

> [532284.563576] BUG: unable to handle kernel paging request at 0000000035c83420
> [532284.564086] IP: [<ffffffff810caf17>] cpuacct_charge+0x97/0x1e0
> [532284.564086] PGD 116369067 PUD 116368067 PMD 0
> [532284.564086] Thread overran stack, or stack corrupted
> [532284.564086] Oops: 0000 [#1] SMP
> [532284.564086] Modules linked in: veth binfmt_misc ip6table_filter ip6_tables tun netlink_diag af_packet_diag udp_diag tcp_diag inet_diag unix_diag bridge stp llc btrfs libcrc32c xor raid6_pq microcode i2c_piix4 joydev virtio_balloon virtio_net pcspkr i2c_core virtio_blk virtio_pci virtio_ring virtio floppy
> [532284.564086] CPU: 2 PID: 2487 Comm: cat Not tainted 3.13.0 #160
> [532284.564086] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
> [532284.564086] task: ffff8800cdb60000 ti: ffff8801167ee000 task.ti: ffff8801167ee000
> [532284.564086] RIP: 0010:[<ffffffff810caf17>]  [<ffffffff810caf17>] cpuacct_charge+0x97/0x1e0
> [532284.564086] RSP: 0018:ffff8801167ee638  EFLAGS: 00010002
> [532284.564086] RAX: 000000000000e540 RBX: 000000000006086c RCX: 000000000000000f
> [532284.564086] RDX: ffffffff81c4e960 RSI: ffffffff81c50640 RDI: 0000000000000046
> [532284.564086] RBP: ffff8801167ee668 R08: 0000000000000003 R09: 0000000000000001
> [532284.564086] R10: 0000000000000001 R11: 0000000000000004 R12: ffff8800cdb60000
> [532284.564086] R13: 00000000167ee038 R14: ffff8800db3576d8 R15: 000080ee26ec7dcf
> [532284.564086] FS:  00007fc30ecc7740(0000) GS:ffff88011b200000(0000) knlGS:0000000000000000
> [532284.564086] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [532284.564086] CR2: 0000000035c83420 CR3: 000000011f966000 CR4: 00000000000006e0
> [532284.564086] Stack:
> [532284.564086]  ffffffff810cae80 ffff880100000014 ffff8800db333480 000000000006086c
> [532284.564086]  ffff8800cdb60068 ffff8800cdb60000 ffff8801167ee6a8 ffffffff810b948f
> [532284.564086]  ffff8801167ee698 ffff8800cdb60068 ffff8800db333480 0000000000000001
> [532284.564086] Call Trace:
> [532284.564086]  [<ffffffff810cae80>] ? cpuacct_css_alloc+0xb0/0xb0
> [532284.564086]  [<ffffffff810b948f>] update_curr+0x13f/0x220
> [532284.564086]  [<ffffffff810bfeb4>] dequeue_entity+0x24/0x5b0
> [532284.564086]  [<ffffffff8101ea59>] ? sched_clock+0x9/0x10
> [532284.564086]  [<ffffffff810c0489>] dequeue_task_fair+0x49/0x430
> [532284.564086]  [<ffffffff810acbb3>] dequeue_task+0x73/0x90
> [532284.564086]  [<ffffffff810acbf3>] deactivate_task+0x23/0x30
> [532284.564086]  [<ffffffff81745b11>] __schedule+0x501/0x960
> [532284.564086]  [<ffffffff817460b9>] schedule+0x29/0x70
> [532284.564086]  [<ffffffff81744eac>] schedule_timeout+0x14c/0x2a0
> [532284.564086]  [<ffffffff810835f0>] ? del_timer+0x70/0x70
> [532284.564086]  [<ffffffff8174b7d0>] ? _raw_spin_unlock_irqrestore+0x40/0x80
> [532284.564086]  [<ffffffff8174547f>] io_schedule_timeout+0x9f/0x100
> [532284.564086]  [<ffffffff810d16dd>] ? trace_hardirqs_on+0xd/0x10
> [532284.564086]  [<ffffffff81182b22>] mempool_alloc+0x152/0x180
> [532284.564086]  [<ffffffff810c56e0>] ? bit_waitqueue+0xd0/0xd0
> [532284.564086]  [<ffffffff810558c7>] ? kvm_clock_read+0x27/0x40

You've clipped the most interesting part of the trace, we don't know what 
was calling mempool_alloc() and must have used a ton of stack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
