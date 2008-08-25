Received: from localhost (localhost.localdomain [127.0.0.1])
	by mx.iplabs.de (Postfix) with ESMTP id 96B6D240537A
	for <linux-mm@kvack.org>; Mon, 25 Aug 2008 19:26:25 +0200 (CEST)
Received: from mx.iplabs.de ([127.0.0.1])
	by localhost (osiris.iplabs.de [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id bh3cBKrQyZ4N for <linux-mm@kvack.org>;
	Mon, 25 Aug 2008 19:26:14 +0200 (CEST)
Received: from [192.168.178.32] (p5088A64A.dip0.t-ipconnect.de [80.136.166.74])
	by mx.iplabs.de (Postfix) with ESMTP id E64D62405379
	for <linux-mm@kvack.org>; Mon, 25 Aug 2008 19:26:13 +0200 (CEST)
Message-ID: <48B2EB37.2000200@iplabs.de>
Date: Mon, 25 Aug 2008 19:26:15 +0200
From: Marco Nietz <m.nietz-mm@iplabs.de>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B2D615.4060509@linux-foundation.org> <48B2DB58.2010304@iplabs.de> <48B2DDDA.5010200@linux-foundation.org>
In-Reply-To: <48B2DDDA.5010200@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's should be possible to reproduce the oom, but it's a Production Server.

The oom happens after if've increased the Maximum Connections and 
Shared-Buffers for the Postgres Database Server on that Machine.

It's kernel: 2.6.18-6-686-bigmem a Debian Etch Server.

And here is the Complete dmesg:

oom-killer: gfp_mask=0xd0, order=0
  [<c014290b>] out_of_memory+0x25/0x13a
  [<c0143d74>] __alloc_pages+0x1f5/0x275
  [<c024c64e>] tcp_sendmsg+0x4da/0x98a
  [<c0125ba1>] __mod_timer+0x99/0xa3
  [<c026381b>] inet_sendmsg+0x35/0x3f
  [<c02204c3>] sock_sendmsg+0xce/0xe8
  [<c012e01d>] autoremove_wake_function+0x0/0x2d
  [<c0258d60>] tcp_v4_do_rcv+0x25/0x2b4
  [<f8fe8114>] ip_confirm+0x27/0x2c [ip_conntrack]
  [<c025b18d>] tcp_v4_rcv+0x8d2/0x925
  [<c0220a20>] sys_sendto+0x116/0x140
  [<c0225a29>] __alloc_skb+0x49/0xf2
  [<c022650b>] __netdev_alloc_skb+0x12/0x2a
  [<f885bb5f>] e1000_alloc_rx_buffers_ps+0xf3/0x1ff [e1000]
  [<f885e0b7>] e1000_clean_rx_irq_ps+0x48a/0x4a2 [e1000]
  [<c02252e3>] kfree_skbmem+0x8/0x63
  [<c0220a63>] sys_send+0x19/0x1d
  [<c0221d88>] sys_socketcall+0xd2/0x181
  [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:161
cpu 0 cold: high 62, batch 15 used:47
cpu 1 hot: high 186, batch 31 used:170
cpu 1 cold: high 62, batch 15 used:51
cpu 2 hot: high 186, batch 31 used:156
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:33
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:77
cpu 4 cold: high 62, batch 15 used:60
cpu 5 hot: high 186, batch 31 used:82
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:105
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:36
cpu 7 cold: high 62, batch 15 used:56
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:110
cpu 0 cold: high 62, batch 15 used:1
cpu 1 hot: high 186, batch 31 used:141
cpu 1 cold: high 62, batch 15 used:8
cpu 2 hot: high 186, batch 31 used:25
cpu 2 cold: high 62, batch 15 used:13
cpu 3 hot: high 186, batch 31 used:25
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:82
cpu 4 cold: high 62, batch 15 used:2
cpu 5 hot: high 186, batch 31 used:153
cpu 5 cold: high 62, batch 15 used:12
cpu 6 hot: high 186, batch 31 used:98
cpu 6 cold: high 62, batch 15 used:3
cpu 7 hot: high 186, batch 31 used:34
cpu 7 cold: high 62, batch 15 used:7
Free pages:       47480kB (40200kB HighMem)
Active:2252481 inactive:1698658 dirty:5471 writeback:10 unstable:0 
free:11870 slab:35170 mapped:140818 pagetables:152848
DMA free:3588kB min:68kB low:84kB high:100kB active:0kB inactive:12kB 
present:16384kB pages_scanned:9 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3692kB min:3756kB low:4692kB high:5632kB active:112kB 
inactive:276kB present:901120kB pages_scanned:899 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:40200kB min:512kB low:18148kB high:35784kB active:9009812kB 
inactive:6794344kB present:16908288kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 0*4096kB = 3588kB
DMA32: empty
Normal: 1*4kB 1*8kB 0*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 3692kB
HighMem: 132*4kB 581*8kB 1039*16kB 191*32kB 184*64kB 2*128kB 1*256kB 
0*512kB 0*1024kB 0*2048kB 0*4096kB = 40200kB
Swap cache: add 216611, delete 216318, find 112681/129891, race 0+3
Free swap  = 7803264kB
Total swap = 7815612kB
Free swap:       7803264kB
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
15946987 pages shared
293 pages swap cached
5580 pages dirty
10 pages writeback
140818 pages mapped
35170 pages slab
152848 pages pagetables
Out of Memory: Kill process 27934 (postmaster) score 22552458 and children.
Out of memory: Killed process 27937 (postmaster).
oom-killer: gfp_mask=0x84d0, order=0
  [<c014290b>] out_of_memory+0x25/0x13a
  [<c0143d74>] __alloc_pages+0x1f5/0x275
  [<c014a439>] __pte_alloc+0x11/0x9e
  [<c014a576>] __handle_mm_fault+0xb0/0xa1f
  [<f8e12356>] start_next_msg+0xc/0x91 [ipmi_si]
  [<f8e126b5>] smi_event_handler+0x2da/0x338 [ipmi_si]
  [<c0125a90>] lock_timer_base+0x15/0x2f
  [<c01155b7>] do_page_fault+0x23b/0x59a
  [<c0117c15>] try_to_wake_up+0x355/0x35f
  [<c011537c>] do_page_fault+0x0/0x59a
  [<c01037f5>] error_code+0x39/0x40
  [<c013f966>] file_read_actor+0x27/0xca
  [<c014016e>] do_generic_mapping_read+0x177/0x42a
  [<c0140c60>] __generic_file_aio_read+0x16b/0x1b2
  [<c013f93f>] file_read_actor+0x0/0xca
  [<f9057e1d>] xfs_read+0x26f/0x2d8 [xfs]
  [<c015538e>] shmem_nopage+0x9d/0xad
  [<f9054e1b>] xfs_file_aio_read+0x5c/0x64 [xfs]
  [<c015906f>] do_sync_read+0xb6/0xf1
  [<c012e01d>] autoremove_wake_function+0x0/0x2d
  [<c0158fb9>] do_sync_read+0x0/0xf1
  [<c0159978>] vfs_read+0x9f/0x141
  [<c0159dc4>] sys_read+0x3c/0x63
  [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:128
cpu 0 cold: high 62, batch 15 used:48
cpu 1 hot: high 186, batch 31 used:30
cpu 1 cold: high 62, batch 15 used:47
cpu 2 hot: high 186, batch 31 used:35
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:79
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:8
cpu 4 cold: high 62, batch 15 used:53
cpu 5 hot: high 186, batch 31 used:162
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:181
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:9
cpu 7 cold: high 62, batch 15 used:58
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:7
cpu 0 cold: high 62, batch 15 used:9
cpu 1 hot: high 186, batch 31 used:47
cpu 1 cold: high 62, batch 15 used:1
cpu 2 hot: high 186, batch 31 used:102
cpu 2 cold: high 62, batch 15 used:7
cpu 3 hot: high 186, batch 31 used:133
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:172
cpu 4 cold: high 62, batch 15 used:14
cpu 5 hot: high 186, batch 31 used:11
cpu 5 cold: high 62, batch 15 used:14
cpu 6 hot: high 186, batch 31 used:30
cpu 6 cold: high 62, batch 15 used:2
cpu 7 hot: high 186, batch 31 used:99
cpu 7 cold: high 62, batch 15 used:3
Free pages:     5949196kB (5941944kB HighMem)
Active:1102138 inactive:1373656 dirty:4831 writeback:0 unstable:0 
free:1487299 slab:35543 mapped:139487 pagetables:152485
DMA free:3588kB min:68kB low:84kB high:100kB active:0kB inactive:40kB 
present:16384kB pages_scanned:40 all_unreclaimable? yes
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB 
inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:5941944kB min:512kB low:18148kB high:35784kB 
active:4408272kB inactive:5494340kB present:16908288kB pages_scanned:0 
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 0*4096kB = 3588kB
DMA32: empty
Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 3664kB
HighMem: 331962*4kB 303446*8kB 105186*16kB 14856*32kB 432*64kB 2*128kB 
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5941944kB
Swap cache: add 216611, delete 216611, find 112681/129891, race 0+3
Free swap  = 7815516kB
Total swap = 7815612kB
Free swap:       7815516kB
oom-killer: gfp_mask=0x84d0, order=0
  [<c014290b>] out_of_memory+0x25/0x13a
  [<c0143d74>] __alloc_pages+0x1f5/0x275
  [<c014a439>] __pte_alloc+0x11/0x9e
  [<c014b864>] copy_page_range+0x155/0x3da
  [<c01ba1d8>] vsnprintf+0x419/0x457
  [<c011c184>] copy_process+0xa73/0x10a9
  [<c011ca1f>] do_fork+0x91/0x17a
  [<c0124d67>] do_gettimeofday+0x31/0xce
  [<c01012c2>] sys_clone+0x28/0x2d
  [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:128
cpu 0 cold: high 62, batch 15 used:48
cpu 1 hot: high 186, batch 31 used:30
cpu 1 cold: high 62, batch 15 used:47
cpu 2 hot: high 186, batch 31 used:35
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:79
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:8
cpu 4 cold: high 62, batch 15 used:53
cpu 5 hot: high 186, batch 31 used:162
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:181
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:9
cpu 7 cold: high 62, batch 15 used:58
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:18
cpu 0 cold: high 62, batch 15 used:9
cpu 1 hot: high 186, batch 31 used:47
cpu 1 cold: high 62, batch 15 used:1
cpu 2 hot: high 186, batch 31 used:102
cpu 2 cold: high 62, batch 15 used:7
cpu 3 hot: high 186, batch 31 used:133
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:172
cpu 4 cold: high 62, batch 15 used:14
cpu 5 hot: high 186, batch 31 used:9
cpu 5 cold: high 62, batch 15 used:14
cpu 6 hot: high 186, batch 31 used:30
cpu 6 cold: high 62, batch 15 used:2
cpu 7 hot: high 186, batch 31 used:99
cpu 7 cold: high 62, batch 15 used:3
Free pages:     5948948kB (5941696kB HighMem)
Active:1102194 inactive:1373658 dirty:4831 writeback:0 unstable:0 
free:1487237 slab:35543 mapped:139487 pagetables:152485
DMA free:3588kB min:68kB low:84kB high:100kB active:0kB inactive:40kB 
present:16384kB pages_scanned:40 all_unreclaimable? yes
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB 
inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:5941696kB min:512kB low:18148kB high:35784kB 
active:4408496kB inactive:5494348kB present:16908288kB pages_scanned:0 
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 0*4096kB = 3588kB
DMA32: empty
Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 3664kB
HighMem: 331900*4kB 303446*8kB 105186*16kB 14856*32kB 432*64kB 2*128kB 
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5941696kB
Swap cache: add 216611, delete 216611, find 112681/129891, race 0+3
Free swap  = 7815516kB
Total swap = 7815612kB
Free swap:       7815516kB
oom-killer: gfp_mask=0xd0, order=0
  [<c014290b>] out_of_memory+0x25/0x13a
  [<c0143d74>] __alloc_pages+0x1f5/0x275
  [<c015653f>] cache_alloc_refill+0x293/0x487
  [<c015630f>] cache_alloc_refill+0x63/0x487
  [<c01562a3>] kmem_cache_alloc+0x32/0x3b
  [<c011b799>] copy_process+0x88/0x10a9
  [<c012bfad>] alloc_pid+0x1ba/0x211
  [<c011ca1f>] do_fork+0x91/0x17a
  [<c0124d67>] do_gettimeofday+0x31/0xce
  [<c01012c2>] sys_clone+0x28/0x2d
  [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:128
cpu 0 cold: high 62, batch 15 used:48
cpu 1 hot: high 186, batch 31 used:30
cpu 1 cold: high 62, batch 15 used:47
cpu 2 hot: high 186, batch 31 used:35
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:79
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:8
cpu 4 cold: high 62, batch 15 used:53
cpu 5 hot: high 186, batch 31 used:162
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:181
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:9
cpu 7 cold: high 62, batch 15 used:58
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:18
cpu 0 cold: high 62, batch 15 used:9
cpu 1 hot: high 186, batch 31 used:47
cpu 1 cold: high 62, batch 15 used:1
cpu 2 hot: high 186, batch 31 used:102
cpu 2 cold: high 62, batch 15 used:7
cpu 3 hot: high 186, batch 31 used:133
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:172
cpu 4 cold: high 62, batch 15 used:14
cpu 5 hot: high 186, batch 31 used:7
cpu 5 cold: high 62, batch 15 used:14
cpu 6 hot: high 186, batch 31 used:29
cpu 6 cold: high 62, batch 15 used:2
cpu 7 hot: high 186, batch 31 used:99
cpu 7 cold: high 62, batch 15 used:3
Free pages:     5948948kB (5941696kB HighMem)
Active:1102194 inactive:1373660 dirty:4831 writeback:0 unstable:0 
free:1487237 slab:35543 mapped:139487 pagetables:152485
DMA free:3588kB min:68kB low:84kB high:100kB active:0kB inactive:40kB 
present:16384kB pages_scanned:40 all_unreclaimable? yes
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB 
inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:5941696kB min:512kB low:18148kB high:35784kB 
active:4408496kB inactive:5494356kB present:16908288kB pages_scanned:0 
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 0*4096kB = 3588kB
DMA32: empty
Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 3664kB
HighMem: 331900*4kB 303446*8kB 105186*16kB 14856*32kB 432*64kB 2*128kB 
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5941696kB
Swap cache: add 216611, delete 216611, find 112681/129891, race 0+3
Free swap  = 7815516kB
Total swap = 7815612kB
Free swap:       7815516kB
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
7272664 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35543 pages slab
152485 pages pagetables
Out of Memory: Kill process 27934 (postmaster) score 28021408 and children.
Out of memory: Killed process 28957 (postmaster).
oom-killer: gfp_mask=0x84d0, order=0
  [<c014290b>] out_of_memory+0x25/0x13a
  [<c0143d74>] __alloc_pages+0x1f5/0x275
  [<c014a439>] __pte_alloc+0x11/0x9e
  [<c014a576>] __handle_mm_fault+0xb0/0xa1f
  [<f8e12356>] start_next_msg+0xc/0x91 [ipmi_si]
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
7271308 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35543 pages slab
152485 pages pagetables
  [<f8e126b5>] smi_event_handler+0x2da/0x338 [ipmi_si]
  [<c0125a90>] lock_timer_base+0x15/0x2f
  [<c01155b7>] do_page_fault+0x23b/0x59a
  [<c0117c15>] try_to_wake_up+0x355/0x35f
  [<c011537c>] do_page_fault+0x0/0x59a
  [<c01037f5>] error_code+0x39/0x40
  [<c013f966>] file_read_actor+0x27/0xca
  [<c014016e>] do_generic_mapping_read+0x177/0x42a
  [<c0140c60>] __generic_file_aio_read+0x16b/0x1b2
  [<c013f93f>] file_read_actor+0x0/0xca
  [<f9057e1d>] xfs_read+0x26f/0x2d8 [xfs]
  [<c015538e>] shmem_nopage+0x9d/0xad
  [<f9054e1b>] xfs_file_aio_read+0x5c/0x64 [xfs]
  [<c015906f>] do_sync_read+0xb6/0xf1
  [<c012e01d>] autoremove_wake_function+0x0/0x2d
  [<c0158fb9>] do_sync_read+0x0/0xf1
  [<c0159978>] vfs_read+0x9f/0x141
  [<c0159dc4>] sys_read+0x3c/0x63
  [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:128
cpu 0 cold: high 62, batch 15 used:48
cpu 1 hot: high 186, batch 31 used:30
cpu 1 cold: high 62, batch 15 used:47
cpu 2 hot: high 186, batch 31 used:35
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:79
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:8
cpu 4 cold: high 62, batch 15 used:53
cpu 5 hot: high 186, batch 31 used:162
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:181
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:9
cpu 7 cold: high 62, batch 15 used:58
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:18
cpu 0 cold: high 62, batch 15 used:9
cpu 1 hot: high 186, batch 31 used:47
cpu 1 cold: high 62, batch 15 used:1
cpu 2 hot: high 186, batch 31 used:102
cpu 2 cold: high 62, batch 15 used:7
cpu 3 hot: high 186, batch 31 used:171
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:172
cpu 4 cold: high 62, batch 15 used:14
cpu 5 hot: high 186, batch 31 used:28
cpu 5 cold: high 62, batch 15 used:14
cpu 6 hot: high 186, batch 31 used:29
cpu 6 cold: high 62, batch 15 used:2
cpu 7 hot: high 186, batch 31 used:99
cpu 7 cold: high 62, batch 15 used:3
Free pages:     5949072kB (5941820kB HighMem)
Active:1102100 inactive:1373664 dirty:4831 writeback:0 unstable:0 
free:1487268 slab:35543 mapped:139487 pagetables:152485
DMA free:3588kB min:68kB low:84kB high:100kB active:24kB inactive:16kB 
present:16384kB pages_scanned:74 all_unreclaimable? yes
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB 
inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:5941820kB min:512kB low:18148kB high:35784kB 
active:4408096kB inactive:5494396kB present:16908288kB pages_scanned:0 
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 0*4096kB = 3588kB
DMA32: empty
Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 3664kB
HighMem: 331931*4kB 303446*8kB 105186*16kB 14856*32kB 432*64kB 2*128kB 
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5941820kB
Swap cache: add 216611, delete 216611, find 112681/129891, race 0+3
Free swap  = 7815516kB
Total swap = 7815612kB
Free swap:       7815516kB
oom-killer: gfp_mask=0xd0, order=0
  [<c014290b>] out_of_memory+0x25/0x13a
  [<c0143d74>] __alloc_pages+0x1f5/0x275
  [<c015653f>] cache_alloc_refill+0x293/0x487
  [<c015630f>] cache_alloc_refill+0x63/0x487
  [<c01562a3>] kmem_cache_alloc+0x32/0x3b
  [<c011b799>] copy_process+0x88/0x10a9
  [<c012bfad>] alloc_pid+0x1ba/0x211
  [<c011ca1f>] do_fork+0x91/0x17a
  [<c0124d67>] do_gettimeofday+0x31/0xce
  [<c01012c2>] sys_clone+0x28/0x2d
  [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:128
cpu 0 cold: high 62, batch 15 used:48
cpu 1 hot: high 186, batch 31 used:30
cpu 1 cold: high 62, batch 15 used:47
cpu 2 hot: high 186, batch 31 used:35
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:79
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:8
cpu 4 cold: high 62, batch 15 used:53
cpu 5 hot: high 186, batch 31 used:162
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:181
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:9
cpu 7 cold: high 62, batch 15 used:58
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:18
cpu 0 cold: high 62, batch 15 used:9
cpu 1 hot: high 186, batch 31 used:47
cpu 1 cold: high 62, batch 15 used:1
cpu 2 hot: high 186, batch 31 used:102
cpu 2 cold: high 62, batch 15 used:7
cpu 3 hot: high 186, batch 31 used:171
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:172
cpu 4 cold: high 62, batch 15 used:14
cpu 5 hot: high 186, batch 31 used:28
cpu 5 cold: high 62, batch 15 used:14
cpu 6 hot: high 186, batch 31 used:29
cpu 6 cold: high 62, batch 15 used:2
cpu 7 hot: high 186, batch 31 used:99
cpu 7 cold: high 62, batch 15 used:3
Free pages:     5949072kB (5941820kB HighMem)
Active:1102100 inactive:1373664 dirty:4831 writeback:0 unstable:0 
free:1487268 slab:35543 mapped:139487 pagetables:152485
DMA free:3588kB min:68kB low:84kB high:100kB active:24kB inactive:16kB 
present:16384kB pages_scanned:74 all_unreclaimable? yes
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB 
inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:5941820kB min:512kB low:18148kB high:35784kB 
active:4408096kB inactive:5494396kB present:16908288kB pages_scanned:0 
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 0*4096kB = 3588kB
DMA32: empty
Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 3664kB
HighMem: 331931*4kB 303446*8kB 105186*16kB 14856*32kB 432*64kB 2*128kB 
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5941820kB
Swap cache: add 216611, delete 216611, find 112681/129891, race 0+3
Free swap  = 7815516kB
Total swap = 7815612kB
Free swap:       7815516kB
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
7264880 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35543 pages slab
152485 pages pagetables
oom-killer: gfp_mask=0x84d0, order=0
  [<c014290b>] out_of_memory+0x25/0x13a
  [<c0143d74>] __alloc_pages+0x1f5/0x275
  [<c014a439>] __pte_alloc+0x11/0x9e
  [<c014b864>] copy_page_range+0x155/0x3da
  [<c01ba1d8>] vsnprintf+0x419/0x457
  [<c011c184>] copy_process+0xa73/0x10a9
  [<c011ca1f>] do_fork+0x91/0x17a
  [<c0124d67>] do_gettimeofday+0x31/0xce
  [<c01012c2>] sys_clone+0x28/0x2d
  [<c0102c0d>] sysenter_past_esp+0x56/0x79
Mem-info:
DMA per-cpu:
cpu 0 hot: high 0, batch 1 used:0
cpu 0 cold: high 0, batch 1 used:0
cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
cpu 2 hot: high 0, batch 1 used:0
cpu 2 cold: high 0, batch 1 used:0
cpu 3 hot: high 0, batch 1 used:0
cpu 3 cold: high 0, batch 1 used:0
cpu 4 hot: high 0, batch 1 used:0
cpu 4 cold: high 0, batch 1 used:0
cpu 5 hot: high 0, batch 1 used:0
cpu 5 cold: high 0, batch 1 used:0
cpu 6 hot: high 0, batch 1 used:0
cpu 6 cold: high 0, batch 1 used:0
cpu 7 hot: high 0, batch 1 used:0
cpu 7 cold: high 0, batch 1 used:0
DMA32 per-cpu: empty
Normal per-cpu:
cpu 0 hot: high 186, batch 31 used:128
cpu 0 cold: high 62, batch 15 used:48
cpu 1 hot: high 186, batch 31 used:30
cpu 1 cold: high 62, batch 15 used:47
cpu 2 hot: high 186, batch 31 used:35
cpu 2 cold: high 62, batch 15 used:59
cpu 3 hot: high 186, batch 31 used:79
cpu 3 cold: high 62, batch 15 used:55
cpu 4 hot: high 186, batch 31 used:8
cpu 4 cold: high 62, batch 15 used:53
cpu 5 hot: high 186, batch 31 used:162
cpu 5 cold: high 62, batch 15 used:52
cpu 6 hot: high 186, batch 31 used:181
cpu 6 cold: high 62, batch 15 used:57
cpu 7 hot: high 186, batch 31 used:9
cpu 7 cold: high 62, batch 15 used:58
HighMem per-cpu:
cpu 0 hot: high 186, batch 31 used:18
cpu 0 cold: high 62, batch 15 used:9
cpu 1 hot: high 186, batch 31 used:47
cpu 1 cold: high 62, batch 15 used:1
cpu 2 hot: high 186, batch 31 used:102
cpu 2 cold: high 62, batch 15 used:7
cpu 3 hot: high 186, batch 31 used:171
cpu 3 cold: high 62, batch 15 used:7
cpu 4 hot: high 186, batch 31 used:172
cpu 4 cold: high 62, batch 15 used:14
cpu 5 hot: high 186, batch 31 used:26
cpu 5 cold: high 62, batch 15 used:14
cpu 6 hot: high 186, batch 31 used:29
cpu 6 cold: high 62, batch 15 used:2
cpu 7 hot: high 186, batch 31 used:99
cpu 7 cold: high 62, batch 15 used:3
Free pages:     5949076kB (5941820kB HighMem)
Active:1102100 inactive:1373666 dirty:4831 writeback:0 unstable:0 
free:1487269 slab:35543 mapped:139487 pagetables:152485
DMA free:3592kB min:68kB low:84kB high:100kB active:24kB inactive:16kB 
present:16384kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 880 17392
Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB 
inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
lowmem_reserve[]: 0 0 0 132096
HighMem free:5941820kB min:512kB low:18148kB high:35784kB 
active:4408096kB inactive:5494404kB present:16908288kB pages_scanned:0 
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 2*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 
1*2048kB 0*4096kB = 3592kB
DMA32: empty
Normal: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 
1*1024kB 1*2048kB 0*4096kB = 3664kB
HighMem: 331931*4kB 303446*8kB 105186*16kB 14856*32kB 432*64kB 2*128kB 
1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5941820kB
Swap cache: add 216611, delete 216611, find 112681/129891, race 0+3
Free swap  = 7815516kB
Total swap = 7815612kB
Free swap:       7815516kB
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
7012372 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35576 pages slab
142180 pages pagetables
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
6977702 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35609 pages slab
138447 pages pagetables
4456448 pages of RAM
4227072 pages of HIGHMEM
299142 reserved pages
6901408 pages shared
0 pages swap cached
4831 pages dirty
0 pages writeback
139487 pages mapped
35576 pages slab
134910 pages pagetables



Christoph Lameter schrieb:
> The output seem to have been from another run.
> 
> Can you reproduce the oom? Which kernel version is this? The full dmesg output
> may help.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
