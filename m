Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 919706B0083
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 20:06:57 -0400 (EDT)
Received: by iwn12 with SMTP id 12so408324iwn.11
        for <linux-mm@kvack.org>; Fri, 04 Sep 2009 17:06:59 -0700 (PDT)
MIME-Version: 1.0
From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Date: Fri, 4 Sep 2009 17:06:39 -0700
Message-ID: <43e72e890909041706u12f271eq2317c69038c73c2@mail.gmail.com>
Subject: process_zones() kmemleak on 2.6.31-rc8
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I get these kmemleak reports on 2.6.31-rc8 + Catalin's
git://linux-arm.org/linux-2.6 kmemleak branch. This kmemleak report
sticks there even after further scans issued manually.

unreferenced object 0xffff88003e001040 (size 64):
  comm "swapper", pid 0, jiffies 4294892296
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
    50 10 00 3e 00 88 ff ff 50 10 00 3e 00 88 ff ff  P..>....P..>....
  backtrace:
    [<ffffffff814e9d55>] kmemleak_alloc+0x25/0x60
    [<ffffffff81118a83>] kmem_cache_alloc_node+0x193/0x200
    [<ffffffff814fa09e>] process_zones+0x70/0x1cd
    [<ffffffff8180d4c5>] setup_per_cpu_pageset+0x11/0x27
    [<ffffffff817f0016>] start_kernel+0x371/0x415
    [<ffffffff817ef61a>] x86_64_start_reservations+0x125/0x129
    [<ffffffff817ef718>] x86_64_start_kernel+0xfa/0x109
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003e0015c0 (size 64):
  comm "swapper", pid 1, jiffies 4294892353
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  ................
    d0 15 00 3e 00 88 ff ff d0 15 00 3e 00 88 ff ff  ...>.......>....
  backtrace:
    [<ffffffff814e9d55>] kmemleak_alloc+0x25/0x60
    [<ffffffff81118a83>] kmem_cache_alloc_node+0x193/0x200
    [<ffffffff814fa09e>] process_zones+0x70/0x1cd
    [<ffffffff814fa230>] pageset_cpuup_callback+0x35/0x92
    [<ffffffff815019b7>] notifier_call_chain+0x47/0x90
    [<ffffffff81078559>] __raw_notifier_call_chain+0x9/0x10
    [<ffffffff814f8f25>] _cpu_up+0x75/0x130
    [<ffffffff814f903a>] cpu_up+0x5a/0x6a
    [<ffffffff817ef97e>] kernel_init+0xcc/0x1ba
    [<ffffffff810130ca>] child_rip+0xa/0x20
    [<ffffffffffffffff>] 0xffffffffffffffff

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
