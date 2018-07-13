Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FABD6B026D
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:42:30 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j9-v6so32822558qtn.22
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:42:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18-v6sor2968484qvn.127.2018.07.13.09.42.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 09:42:29 -0700 (PDT)
Subject: Re: [4.18-rc4] kernel BUG at mm/page_alloc.c:2016!
From: Laura Abbott <labbott@redhat.com>
References: <20180709233656.nzwzsyyomrxqobwk@codemonkey.org.uk>
 <8d62cf07-0cc9-4de3-953a-2203c82b4879@redhat.com>
Message-ID: <4f3ea806-a126-0081-93d8-ca8fa02efdae@redhat.com>
Date: Fri, 13 Jul 2018 09:42:26 -0700
MIME-Version: 1.0
In-Reply-To: <8d62cf07-0cc9-4de3-953a-2203c82b4879@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

(cc a few more people)

On 07/09/2018 05:07 PM, Laura Abbott wrote:
> On 07/09/2018 04:36 PM, Dave Jones wrote:
>> When I ran an rsync on my machine I use for backups, it eventually
>> hits this trace..
>>
>> kernel BUG at mm/page_alloc.c:2016!
>> invalid opcode: 0000 [#1] SMP RIP: move_freepages_block+0x120/0x2d0
>> CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.18.0-rc4-backup+ #1
>> Hardware name: ASUS All Series/Z97-DELUXE, BIOS 2602 08/18/2015
>> RIP: 0010:move_freepages_block+0x120/0x2d0
>> Code: 05 48 01 c8 74 3b f6 00 02 74 36 48 8b 03 48 c1 e8 3e 48 8d 0c 40 48 8b 86 c0 7f 00 00 48 c1 e8 3e 48 8d 04 40 48 39 c8 74 17 <0f> 0b 45 31 f6 48 83 c4 28 44 89 f0 5b 5d 41 5c 41 5d 41 5e 41 5f
>> RSP: 0018:ffff88043fac3af8 EFLAGS: 00010093
>> RAX: 0000000000000000 RBX: ffffea0002e20000 RCX: 0000000000000003
>> RDX: 0000000000000000 RSI: ffffea0002e20000 RDI: 0000000000000000
>> RBP: 0000000000000000 R08: ffff88043fac3b5c R09: ffffffff9295e110
>> R10: ffff88043fdf4000 R11: ffffea0002e20008 R12: ffffea0002e20000
>> R13: ffffffff9295dd40 R14: 0000000000000008 R15: ffffea0002e27fc0
>> FS:A  0000000000000000(0000) GS:ffff88043fac0000(0000) knlGS:0000000000000000
>> CS:A  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00007f2a75f71fe8 CR3: 00000001e380f006 CR4: 00000000001606e0
>> Call Trace:
>> A  <IRQ>
>> A  ? lock_acquire+0xe6/0x1dc
>> A  steal_suitable_fallback+0x152/0x1a0
>> A  get_page_from_freelist+0x1029/0x1650
>> A  ? free_debug_processing+0x271/0x410
>> A  __alloc_pages_nodemask+0x111/0x310
>> A  page_frag_alloc+0x74/0x120
>> A  __netdev_alloc_skb+0x95/0x110
>> A  e1000_alloc_rx_buffers+0x225/0x2b0
>> A  e1000_clean_rx_irq+0x2ee/0x450
>> A  e1000e_poll+0x7c/0x2e0
>> A  net_rx_action+0x273/0x4d0
>> A  __do_softirq+0xc6/0x4d6
>> A  irq_exit+0xbb/0xc0
>> A  do_IRQ+0x60/0x110
>> A  common_interrupt+0xf/0xf
>> A  </IRQ>
>> RIP: 0010:cpuidle_enter_state+0xb5/0x390
>> Code: 89 04 24 0f 1f 44 00 00 31 ff e8 86 26 64 ff 80 7c 24 0f 00 0f 85 fb 01 00 00 e8 66 02 66 ff fb 48 ba cf f7 53 e3 a5 9b c4 20 <48> 8b 0c 24 4c 29 f9 48 89 c8 48 c1 f9 3f 48 f7 ea b8 ff ff ff 7f
>> RSP: 0018:ffffc900000abe70 EFLAGS: 00000202
>> A  ORIG_RAX: ffffffffffffffdc
>> RAX: ffff880107fe8040 RBX: 0000000000000003 RCX: 0000000000000001
>> RDX: 20c49ba5e353f7cf RSI: 0000000000000001 RDI: ffff880107fe8040
>> RBP: ffff88043fae8c20 R08: 0000000000000001 R09: 0000000000000018
>> R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff928fb7d8
>> R13: 0000000000000003 R14: 0000000000000003 R15: 0000015e55aecf23
>> A  do_idle+0x128/0x230
>> A  cpu_startup_entry+0x6f/0x80
>> A  start_secondary+0x192/0x1f0
>> A  secondary_startup_64+0xa5/0xb0
>> NMI watchdog: Watchdog detected hard LOCKUP on cpu 4
>>
>> Everything then locks up & rebooots.
>>
>> It's fairly reproduceable, though every time I run it my rsync gets further, and eventually I suspect it
>> won't create enough load to reproduce.
>>
>> 2006 #ifndef CONFIG_HOLES_IN_ZONE
>> 2007A A A A A A A A  /*
>> 2008A A A A A A A A A  * page_zone is not safe to call in this context when
>> 2009A A A A A A A A A  * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
>> 2010A A A A A A A A A  * anyway as we check zone boundaries in move_freepages_block().
>> 2011A A A A A A A A A  * Remove at a later date when no bug reports exist related to
>> 2012A A A A A A A A A  * grouping pages by mobility
>> 2013A A A A A A A A A  */
>> 2014A A A A A A A A  VM_BUG_ON(pfn_valid(page_to_pfn(start_page)) &&
>> 2015A A A A A A A A A A A A A A A A A A  pfn_valid(page_to_pfn(end_page)) &&
>> 2016A A A A A A A A A A A A A A A A A A  page_zone(start_page) != page_zone(end_page));
>> 2017 #endif
>> 2018
>>
>>
>>
>> A A A A Dave
>>
> 
> Fedora is hitting this as well on 4.17.x, reporter said it started
> with 4.17.4, 4.17.3 was fine. I asked the reporter to bisect
> and was going to send after they got back to me.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1598462
> 
> Thanks,
> Laura

One of the reporters has a bisect in progress and has narrowed
it down to this range (https://bugzilla.redhat.com/show_bug.cgi?id=1598462#c18)

54428453efda x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
ee23f3bd9d40 block: Fix cloning of requests with a special payload
4ef7273f5916 block: Fix transfer when chunk sectors exceeds max
81f318e259d1 pmem: only set QUEUE_FLAG_DAX for fsdax mode
ec43a73489c5 dm: use bio_split() when splitting out the already processed bio
b26c9f368748 kasan: depend on CONFIG_SLUB_DEBUG
916c0db51d3a slub: fix failure when we delete and create a slab cache

I'm suspicious of 54428453efda (x86/e820: put !E820_TYPE_RAM regions into
memblock.reserved) since it seems like that could affect the bounds
of zone regions.

Thanks,
Laura
