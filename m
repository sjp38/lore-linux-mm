Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 536006B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 16:02:13 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so17280763wmi.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 13:02:13 -0800 (PST)
Received: from mifar.in (mifar.in. [46.101.129.31])
        by mx.google.com with ESMTPS id b78si598942wmb.45.2017.01.09.13.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 13:02:11 -0800 (PST)
Received: from mifar.in (host-109-204-146-251.tp-fne.tampereenpuhelin.net [109.204.146.251])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(Client CN "mifar.in", Issuer "mifar.in" (verified OK))
	by mifar.in (Postfix) with ESMTPS id D61315FB53
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 23:02:10 +0200 (EET)
Date: Mon, 9 Jan 2017 23:02:10 +0200
From: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Subject: [BUG] How to crash 4.9.2 x86_64: vmscan: shrink_slab
Message-ID: <20170109210210.2zgvw6nfs4qbgmjw@m.mifar.in>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

# sysctl vm.vfs_cache_pressure=-100

kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535449472
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535450112
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-661702561611775889
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535442432
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562613194205300197
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535439872
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-659655090764208789
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6564660665198832072
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562613194351275164
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562615996648922728
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6564660665198832072
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6562613194351264981
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-569296135781119076
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-565206492037048430
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-565212096665106188
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-569296135781119076
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-565206492037043196
kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-659660388715270673


Alternatively,
# sysctl vm.vfs_cache_pressure=10000000
< allocate 6 GB of RAM on 16 GB system >
< start google-chrome-stable >
infinite loop in khugepaged a?? super_cache_scan

(this was with 4.9.1)

kernel: sysrq: SysRq : Show Regs
kernel: CPU: 2 PID: 353 Comm: khugepaged Tainted: G        W       4.9.1+ #79
kernel: Hardware name: System manufacturer System Product Name/P8Z68-V PRO GEN3, BIOS 3402 05/07/2012
kernel: task: ffffa2e8cc7d9500 task.stack: ffffabe040858000
kernel: RIP: 0010:[<ffffffffa210af9e>]  [<ffffffffa210af9e>] lock_acquire+0xee/0x180
kernel: RSP: 0018:ffffabe04085b860  EFLAGS: 00000286
kernel: RAX: ffffa2e8cc7d9500 RBX: 0000000000000286 RCX: d1055b5d00000000
kernel: RDX: 000000001113d196 RSI: 0000000003e5c7cd RDI: 0000000000000286
kernel: RBP: ffffabe04085b8b8 R08: 0000000000000000 R09: 0000000000000000
kernel: R10: 0000000032ec60fe R11: 0000000000000001 R12: 0000000000000000
kernel: R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
kernel: FS:  0000000000000000(0000) GS:ffffa2e8df100000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 0000371ebec2e004 CR3: 00000004033fb000 CR4: 00000000000406e0
kernel: Stack:
kernel: ffffffffa21c88ed ffffa2e800000000 0000000000000000 0000000000000286
kernel: 000000017ae9f878 ffffa2e87af7de98 ffffa2e87af7de80 ffffffffffffffff
kernel: ffffabe04085b9f8 0000000000000000 0000000000000000 ffffabe04085b8d8
kernel: Call Trace:
kernel: [<ffffffffa21c88ed>] ? __list_lru_count_one.isra.0+0x1d/0x80
kernel: [<ffffffffa294af63>] _raw_spin_lock+0x33/0x50
kernel: [<ffffffffa21c88ed>] ? __list_lru_count_one.isra.0+0x1d/0x80
kernel: [<ffffffffa21c88ed>] __list_lru_count_one.isra.0+0x1d/0x80
kernel: [<ffffffffa21c896e>] list_lru_count_one+0x1e/0x20
kernel: [<ffffffffa220f741>] super_cache_scan+0xa1/0x1a0
kernel: [<ffffffffa21aef6e>] shrink_slab.part.15+0x22e/0x4b0
kernel: [<ffffffffa21af21f>] shrink_slab+0x2f/0x40
kernel: [<ffffffffa21b2c2b>] shrink_node+0xeb/0x2e0
kernel: [<ffffffffa21b2ee7>] do_try_to_free_pages+0xc7/0x2d0
kernel: [<ffffffffa21b31be>] try_to_free_pages+0xce/0x210
kernel: [<ffffffffa21a32a8>] __alloc_pages_nodemask+0x538/0xd60
kernel: [<ffffffffa21fdc33>] khugepaged+0x3a3/0x24a0
kernel: [<ffffffffa21051a0>] ? wake_atomic_t_function+0x50/0x50
kernel: [<ffffffffa21fd890>] ? collapse_shmem.isra.8+0xb00/0xb00
kernel: [<ffffffffa20e29f0>] kthread+0xe0/0x100
kernel: [<ffffffffa20e2910>] ? kthread_park+0x60/0x60
kernel: [<ffffffffa294bb45>] ret_from_fork+0x25/0x30
kernel: Code: 04 24 48 8b 7d d0 49 83 f0 01 41 83 e0 01 e8 aa f2 ff ff 48 89 df 65 48 8b 04 25 00 d4 00 00 c7 80 0c 07 00 00 00 00 00 00 57 9d <66> 66 90 66 90 48 83 c4 30 5b 41 5c 41 5d 41 5e 41 5f 5d c3 65 

-- 
Do what you love because life is too short for anything else.
https://samifar.in/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
