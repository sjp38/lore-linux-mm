Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C28C76B0003
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 19:36:58 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j189-v6so25282641qkf.0
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 16:36:58 -0700 (PDT)
Received: from scorn.kernelslacker.org (scorn.kernelslacker.org. [2600:3c03::f03c:91ff:fe59:ec69])
        by mx.google.com with ESMTPS id t124-v6si15199962qke.86.2018.07.09.16.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Jul 2018 16:36:57 -0700 (PDT)
Received: from [2601:196:4600:5b90:ae9e:17ff:feb7:72ca] (helo=wopr.kernelslacker.org)
	by scorn.kernelslacker.org with esmtp (Exim 4.89)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1fcfiC-00067m-N1
	for linux-mm@kvack.org; Mon, 09 Jul 2018 19:36:56 -0400
Date: Mon, 9 Jul 2018 19:36:56 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: [4.18-rc4] kernel BUG at mm/page_alloc.c:2016!
Message-ID: <20180709233656.nzwzsyyomrxqobwk@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

When I ran an rsync on my machine I use for backups, it eventually
hits this trace..

kernel BUG at mm/page_alloc.c:2016!
invalid opcode: 0000 [#1] SMP RIP: move_freepages_block+0x120/0x2d0
CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.18.0-rc4-backup+ #1
Hardware name: ASUS All Series/Z97-DELUXE, BIOS 2602 08/18/2015
RIP: 0010:move_freepages_block+0x120/0x2d0
Code: 05 48 01 c8 74 3b f6 00 02 74 36 48 8b 03 48 c1 e8 3e 48 8d 0c 40 48 8b 86 c0 7f 00 00 48 c1 e8 3e 48 8d 04 40 48 39 c8 74 17 <0f> 0b 45 31 f6 48 83 c4 28 44 89 f0 5b 5d 41 5c 41 5d 41 5e 41 5f 
RSP: 0018:ffff88043fac3af8 EFLAGS: 00010093
RAX: 0000000000000000 RBX: ffffea0002e20000 RCX: 0000000000000003
RDX: 0000000000000000 RSI: ffffea0002e20000 RDI: 0000000000000000
RBP: 0000000000000000 R08: ffff88043fac3b5c R09: ffffffff9295e110
R10: ffff88043fdf4000 R11: ffffea0002e20008 R12: ffffea0002e20000
R13: ffffffff9295dd40 R14: 0000000000000008 R15: ffffea0002e27fc0
FS:  0000000000000000(0000) GS:ffff88043fac0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f2a75f71fe8 CR3: 00000001e380f006 CR4: 00000000001606e0
Call Trace:
 <IRQ>
 ? lock_acquire+0xe6/0x1dc
 steal_suitable_fallback+0x152/0x1a0
 get_page_from_freelist+0x1029/0x1650
 ? free_debug_processing+0x271/0x410
 __alloc_pages_nodemask+0x111/0x310
 page_frag_alloc+0x74/0x120
 __netdev_alloc_skb+0x95/0x110
 e1000_alloc_rx_buffers+0x225/0x2b0
 e1000_clean_rx_irq+0x2ee/0x450
 e1000e_poll+0x7c/0x2e0
 net_rx_action+0x273/0x4d0
 __do_softirq+0xc6/0x4d6
 irq_exit+0xbb/0xc0
 do_IRQ+0x60/0x110
 common_interrupt+0xf/0xf
 </IRQ>
RIP: 0010:cpuidle_enter_state+0xb5/0x390
Code: 89 04 24 0f 1f 44 00 00 31 ff e8 86 26 64 ff 80 7c 24 0f 00 0f 85 fb 01 00 00 e8 66 02 66 ff fb 48 ba cf f7 53 e3 a5 9b c4 20 <48> 8b 0c 24 4c 29 f9 48 89 c8 48 c1 f9 3f 48 f7 ea b8 ff ff ff 7f 
RSP: 0018:ffffc900000abe70 EFLAGS: 00000202
 ORIG_RAX: ffffffffffffffdc
RAX: ffff880107fe8040 RBX: 0000000000000003 RCX: 0000000000000001
RDX: 20c49ba5e353f7cf RSI: 0000000000000001 RDI: ffff880107fe8040
RBP: ffff88043fae8c20 R08: 0000000000000001 R09: 0000000000000018
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff928fb7d8
R13: 0000000000000003 R14: 0000000000000003 R15: 0000015e55aecf23
 do_idle+0x128/0x230
 cpu_startup_entry+0x6f/0x80
 start_secondary+0x192/0x1f0
 secondary_startup_64+0xa5/0xb0
NMI watchdog: Watchdog detected hard LOCKUP on cpu 4

Everything then locks up & rebooots.

It's fairly reproduceable, though every time I run it my rsync gets further, and eventually I suspect it
won't create enough load to reproduce.

2006 #ifndef CONFIG_HOLES_IN_ZONE
2007         /*
2008          * page_zone is not safe to call in this context when
2009          * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
2010          * anyway as we check zone boundaries in move_freepages_block().
2011          * Remove at a later date when no bug reports exist related to
2012          * grouping pages by mobility
2013          */
2014         VM_BUG_ON(pfn_valid(page_to_pfn(start_page)) &&
2015                   pfn_valid(page_to_pfn(end_page)) &&
2016                   page_zone(start_page) != page_zone(end_page));
2017 #endif
2018 



	Dave
