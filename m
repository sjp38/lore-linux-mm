Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1525A6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 05:39:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id h10so8575834pgn.19
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 02:39:46 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i1si2560219pll.411.2018.01.09.02.39.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Jan 2018 02:39:41 -0800 (PST)
Subject: Re: [mm? 4.15-rc7] Random oopses by simple write under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801052345.JBJ82317.tJVHFFOMOLFOQS@I-love.SAKURA.ne.jp>
In-Reply-To: <201801052345.JBJ82317.tJVHFFOMOLFOQS@I-love.SAKURA.ne.jp>
Message-Id: <201801091939.JDJ64598.HOMFQtOFSOVLFJ@I-love.SAKURA.ne.jp>
Date: Tue, 9 Jan 2018 19:39:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I can hit this bug with Linux 4.11 and 4.8. (i.e. at least all 4.8+ have this bug.)
So far I haven't hit this bug with Linux 4.8-rc3 and 4.7.
Does anyone know what is happening?



As of v4.8:

** 1516 printk messages dropped ** [  131.524698] BUG: unable to handle kernel paging request at 0158de94
** 2263 printk messages dropped ** [  131.529186] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter intel_powerclamp coretemp ppdev vmw_balloon pcspkr shpchp sg vmw_vmci parport_pc parport i2c_piix4 ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
** 11660 printk messages dropped ** [  131.563480] Call Trace:
** 1274 printk messages dropped ** [  131.567313]  [<c55de022>] schedule+0x52/0x70
** 1554 printk messages dropped ** [  131.572008] ------------[ cut here ]------------
** 1669 printk messages dropped ** [  131.577027]  [<c55de022>] schedule+0x52/0x70
** 1185 printk messages dropped ** [  131.580606] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1256 printk messages dropped ** [  131.584396] ESI: 00000001 EDI: e658de3c EBP: e658df58 ESP: e658df2c
** 1719 printk messages dropped ** [  131.589577] ESI: 00000001 EDI: e658de3c EBP: e658df58 ESP: e658df2c
** 1898 printk messages dropped ** [  131.595393] Call Trace:
** 952 printk messages dropped ** [  131.598851] ---[ end trace 27af91326c31342e ]---
** 1522 printk messages dropped ** [  131.603609] BUG: unable to handle kernel paging request at 0158de94
** 2167 printk messages dropped ** [  131.610234] Call Trace:
** 1184 printk messages dropped ** [  131.613877] Fixing recursive fault but reboot is needed!
** 1524 printk messages dropped ** [  131.618480]  [<c55de022>] schedule+0x52/0x70
** 1379 printk messages dropped ** [  131.622669] EIP: [<c523a834>] blk_flush_plug_list+0x54/0x210 SS:ESP 0068:e658df2c
** 2273 printk messages dropped ** [  131.629554] Call Trace:
** 1143 printk messages dropped ** [  131.633005] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1537 printk messages dropped ** [  131.637673] Call Trace:
** 1170 printk messages dropped ** [  131.641177] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1476 printk messages dropped ** [  131.645634]  00000009 e658e000 eb265a40 e658df64 c55de022 00000009 e658dfac c50545b0
** 2235 printk messages dropped ** [  131.652386]  00000009 e658e000 eb265a40 e658df64 c55de022 00000009 e658dfac c50545b0
** 2282 printk messages dropped ** [  131.659252]  [<c50545b0>] do_exit+0x9d0/0xa30
** 1341 printk messages dropped ** [  131.663305] CPU: 7 PID: 7783 Comm: a.out Tainted: G      D W       4.8.0 #1
** 2146 printk messages dropped ** [  131.669755] ------------[ cut here ]------------
** 1362 printk messages dropped ** [  131.673851] CR0: 80050033 CR2: 0158de94 CR3: 33233000 CR4: 000406d0
** 2052 printk messages dropped ** [  131.680023] *pde = 00000000 
** 1165 printk messages dropped ** [  131.683703] task: eb265a40 task.stack: e658c000
** 1326 printk messages dropped ** [  131.687678] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1436 printk messages dropped ** [  131.692003]  [<c55de022>] schedule+0x52/0x70
** 1287 printk messages dropped ** [  131.695871]  c576539c 00000000 00000000 eb265a40 eb265dfc 00000001 eb265c98 eb265a40
** 2133 printk messages dropped ** [  131.702282] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1435 printk messages dropped ** [  131.706608] Call Trace:
** 1118 printk messages dropped ** [  131.709977]  [<c55de022>] schedule+0x52/0x70
** 1295 printk messages dropped ** [  131.713889] ---[ end trace 27af91326c313b16 ]---
** 1332 printk messages dropped ** [  131.717899] ---[ end trace 27af91326c313b54 ]---
** 1321 printk messages dropped ** [  131.721862] Stack:
** 1029 printk messages dropped ** [  131.724942]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
** 1381 printk messages dropped ** [  131.729095] Call Trace:
** 1057 printk messages dropped ** [  131.732279] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1392 printk messages dropped ** [  131.736474] Call Trace:
** 1074 printk messages dropped ** [  131.739687] Call Trace:
** 1036 printk messages dropped ** [  131.742845] EIP: [<c523a834>] blk_flush_plug_list+0x54/0x210 SS:ESP 0068:e658df2c
** 2017 printk messages dropped ** [  131.748890]  [<c50545b0>] do_exit+0x9d0/0xa30
** 1273 printk messages dropped ** [  131.752731] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter intel_powerclamp coretemp ppdev vmw_balloon pcspkr shpchp sg vmw_vmci parport_pc parport i2c_piix4 ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
** 10488 printk messages dropped ** [  131.784217] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1465 printk messages dropped ** [  131.788624] CPU: 7 PID: 7783 Comm: a.out Tainted: G      D W       4.8.0 #1
** 2119 printk messages dropped ** [  131.794935] Call Trace:
** 1155 printk messages dropped ** [  131.798375] CR0: 80050033 CR2: 0158de94 CR3: 33233000 CR4: 000406d0
** 2051 printk messages dropped ** [  131.804506] IP: [<c523a834>] blk_flush_plug_list+0x54/0x210
** 1457 printk messages dropped ** [  131.808872]  [<c55e2291>] rewind_stack_do_exit+0x11/0x13
** 1459 printk messages dropped ** [  131.813214]  [<c5050d35>] warn_slowpath_null+0x25/0x30
** 1418 printk messages dropped ** [  131.817447]  [<c5050d35>] warn_slowpath_null+0x25/0x30
** 1405 printk messages dropped ** [  131.821640] ---[ end trace 27af91326c31419e ]---
** 1332 printk messages dropped ** [  131.825618] ---[ end trace 27af91326c3141dc ]---



As of v4.11:

[  159.748100] BUG: unable to handle kernel paging request at f6f48ca4
[  159.748106] IP: page_remove_rmap+0x7/0x2c0
[  159.748107] *pde = 3732c067 
[  159.748108] *pte = 36f48062 
[  159.748109] 
[  159.748111] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  159.748112] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg ppdev vmw_balloon pcspkr vmw_vmci shpchp parport_pc i2c_piix4 parport ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[  159.748149] CPU: 7 PID: 74 Comm: kswapd0 Not tainted 4.11.0 #266
[  159.748150] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  159.748151] task: f3822840 task.stack: f3766000
[  159.748153] EIP: page_remove_rmap+0x7/0x2c0
[  159.748153] EFLAGS: 00010246 CPU: 7
[  159.748155] EAX: f6f48c90 EBX: f6f48c90 ECX: 00000000 EDX: 00000000
[  159.748156] ESI: e8e78e00 EDI: 000002a2 EBP: f3767c30 ESP: f3767c28
[  159.748157]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  159.748158] CR0: 80050033 CR2: f6f48ca4 CR3: 24c10000 CR4: 000406d0
[  159.748239] Call Trace:
[  159.748255]  try_to_unmap_one+0x206/0x4f0
[  159.748261]  rmap_walk_file+0x13c/0x270
[  159.748262]  rmap_walk+0x32/0x60
[  159.748264]  try_to_unmap+0xad/0x150
[  159.748265]  ? page_remove_rmap+0x2c0/0x2c0
[  159.748267]  ? page_not_mapped+0x10/0x10
[  159.748268]  ? page_get_anon_vma+0x90/0x90
[  159.748271]  shrink_page_list+0x37a/0xd10
[  159.748274]  shrink_inactive_list+0x173/0x370
[  159.748277]  shrink_node_memcg+0x572/0x7d0
[  159.748279]  ? __list_lru_count_one.isra.7+0x14/0x40
[  159.748282]  shrink_node+0xb3/0x2c0
[  159.748284]  kswapd+0x287/0x5b0
[  159.748287]  kthread+0xd7/0x110
[  159.748289]  ? mem_cgroup_shrink_node+0xa0/0xa0
[  159.748291]  ? kthread_park+0x70/0x70
[  159.748294]  ret_from_fork+0x21/0x2c
[  159.748295] Code: ff ff ba 78 50 7a c1 89 d8 e8 a6 f8 fe ff 0f 0b 83 e8 01 e9 66 ff ff ff 8d b6 00 00 00 00 8d bf 00 00 00 00 55 89 e5 56 53 89 c3 <8b> 40 14 a8 01 0f 85 a4 01 00 00 89 d8 f6 40 04 01 74 5e 84 d2
[  159.748321] EIP: page_remove_rmap+0x7/0x2c0 SS:ESP: 0068:f3767c28
[  159.748321] CR2: 00000000f6f48ca4
[  159.748324] ---[ end trace e46bc6bd14f9eb43 ]---



As of ad6b67041a45497261617d7a28b15159b202cb5a:

[   79.478257] BUG: unable to handle kernel paging request at f6df5974
[   79.478263] IP: page_remove_rmap+0x7/0x2c0
[   79.478264] *pde = 3732c067 
[   79.478265] *pte = 36df5062 
[   79.478265] 
[   79.478268] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   79.478269] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg ppdev vmw_balloon pcspkr vmw_vmci parport_pc shpchp i2c_piix4 parport ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[   79.478303] CPU: 5 PID: 978 Comm: a.out Not tainted 4.11.0+ #275
[   79.478304] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   79.478306] task: f15d9e40 task.stack: f0cc8000
[   79.478307] EIP: page_remove_rmap+0x7/0x2c0
[   79.478308] EFLAGS: 00010246 CPU: 5
[   79.478309] EAX: f6df5960 EBX: f6df5960 ECX: 00000000 EDX: 00000000
[   79.478310] ESI: f70d3218 EDI: 0000000f EBP: f0cc9ab8 ESP: f0cc9ab0
[   79.478311]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   79.478313] CR0: 80050033 CR2: f6df5974 CR3: 30b18000 CR4: 000406d0
[   79.478420] Call Trace:
[   79.478424]  try_to_unmap_one+0x200/0x540
[   79.478426]  rmap_walk_file+0x13c/0x270
[   79.478428]  rmap_walk+0x32/0x60
[   79.478429]  try_to_unmap+0x9d/0x120
[   79.478431]  ? page_remove_rmap+0x2c0/0x2c0
[   79.478432]  ? page_not_mapped+0x10/0x10
[   79.478434]  ? page_get_anon_vma+0x80/0x80
[   79.478437]  shrink_page_list+0x38d/0xdd0
[   79.478440]  shrink_inactive_list+0x173/0x360
[   79.478443]  shrink_node_memcg+0x33a/0x720
[   79.478446]  shrink_node+0xbb/0x2e0
[   79.478449]  do_try_to_free_pages+0xb2/0x2a0
[   79.478451]  try_to_free_pages+0xf9/0x330
[   79.478455]  ? schedule_timeout+0x142/0x200
[   79.478458]  __alloc_pages_slowpath+0x343/0x6f8
[   79.478460]  __alloc_pages_nodemask+0x1aa/0x1c0
[   79.478464]  handle_mm_fault+0x5c9/0xdb0
** 49 printk messages dropped ** [   79.572015] Code: 55 d4 88 55 db 89 5d e8 89 5d ec 89 45 dc 90 8b 47 10 39 45 dc 74 52 8b 47 10 39 45 dc 74 20 8b 4f 10 8b 45 e8 8b 57 14 89 4d e8 <89> 59 04 89 02 89 50 04 8b 45 dc 89 47 10 89 47 14 8d 76 00 8b



As of 192d7232569ab61ded40c8be691b12832bc6bcd1:

[  192.152510] BUG: Bad page state in process a.out  pfn:18566
[  192.152513] page:f72997f0 count:0 mapcount:8 mapping:f118f5a4 index:0x0
[  192.152516] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
[  192.152520] raw: 19010019 f118f5a4 00000000 00000007 00000000 f7299804 f7299804 00000000
[  192.152521] raw: 00000000 00000000
[  192.152521] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[  192.152522] bad because of flags: 0x1(locked)
[  192.152523] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp pcspkr sg vmw_balloon ppdev shpchp parport_pc parport vmw_vmci i2c_piix4 ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ata_piix mptscsih e1000 mptbase libata
[  192.152561] CPU: 0 PID: 9717 Comm: a.out Not tainted 4.11.0+ #276
[  192.152562] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  192.152563] Call Trace:
[  192.152572]  dump_stack+0x58/0x76
[  192.152577]  bad_page+0xbf/0x130
[  192.152581]  free_pages_check_bad+0x5b/0x5e
[  192.152583]  free_hot_cold_page+0x211/0x250
[  192.152586]  __put_page+0x30/0x40
[  192.152588]  try_to_unmap_one+0x375/0x550
[  192.152590]  rmap_walk_file+0x13c/0x270
[  192.152592]  rmap_walk+0x32/0x60
[  192.152593]  try_to_unmap+0x9d/0x120
[  192.152595]  ? page_remove_rmap+0x2c0/0x2c0
[  192.152596]  ? page_not_mapped+0x10/0x10
[  192.152598]  ? page_get_anon_vma+0x80/0x80
[  192.152601]  shrink_page_list+0x376/0xdf0
[  192.152604]  shrink_inactive_list+0x173/0x360
[  192.152607]  shrink_node_memcg+0x33a/0x720
[  192.152609]  shrink_node+0xbb/0x2e0
[  192.152612]  do_try_to_free_pages+0xb2/0x2a0
[  192.152615]  try_to_free_pages+0xf9/0x330
[  192.152619]  ? schedule_timeout+0x142/0x200
[  192.152622]  __alloc_pages_slowpath+0x343/0x6f8
[  192.152624]  __alloc_pages_nodemask+0x1aa/0x1c0
[  192.152627]  handle_mm_fault+0x5c9/0xdb0
[  192.152629]  ? filemap_fdatawait+0x50/0x50
[  192.152633]  __do_page_fault+0x19c/0x460
[  192.152635]  ? __do_page_fault+0x460/0x460
[  192.152637]  do_page_fault+0x1a/0x20
[  192.152639]  common_exception+0x6c/0x72
[  192.152641] EIP: 0x804858f
[  192.152642] EFLAGS: 00010202 CPU: 0
[  192.152643] EAX: 02d8b000 EBX: 37689008 ECX: 3a414008 EDX: 00000000
[  192.152644] ESI: 7ff00000 EDI: 00000000 EBP: bfd2b608 ESP: bfd2b5d0
[  192.152645]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  192.152647] Disabling lock debugging due to kernel taint
[  192.152652] page:f72997f0 count:0 mapcount:0 mapping:f118f5a4 index:0x0
[  192.152654] flags: 0x19030078(uptodate|dirty|lru|active|mappedtodisk|reclaim)
[  192.152656] raw: 19030078 f118f5a4 00000000 ffffffff 00000000 f400c2d8 f400c2d8 00000000
[  192.152657] raw: 00000000 00000000
[  192.152658] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[  192.152668] ------------[ cut here ]------------
[  192.152669] kernel BUG at ./include/linux/mm.h:466!
[  192.152671] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  192.152672] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp pcspkr sg vmw_balloon ppdev shpchp parport_pc parport vmw_vmci i2c_piix4 ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ata_piix mptscsih e1000 mptbase libata
[  192.152697] CPU: 0 PID: 9717 Comm: a.out Tainted: G    B           4.11.0+ #276
[  192.152698] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  192.152699] task: def05a40 task.stack: dde1a000
[  192.152701] EIP: put_page_testzero.part.46+0xd/0xf
[  192.152702] EFLAGS: 00010092 CPU: 0
[  192.152703] EAX: 00000000 EBX: f400c2c0 ECX: c1870e80 EDX: 00000002
[  192.152704] ESI: f7299804 EDI: 00000003 EBP: dde1bbec ESP: dde1bbec
[  192.152705]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  192.152706] CR0: 80050033 CR2: b7505dec CR3: 2c682000 CR4: 000406d0
[  192.152793] Call Trace:
[  192.152797]  putback_inactive_pages+0x384/0x3c0
[  192.152800]  shrink_inactive_list+0x193/0x360
[  192.152802]  shrink_node_memcg+0x33a/0x720
[  192.152805]  shrink_node+0xbb/0x2e0
[  192.152808]  do_try_to_free_pages+0xb2/0x2a0
[  192.152810]  try_to_free_pages+0xf9/0x330
[  192.152813]  ? schedule_timeout+0x142/0x200
[  192.152815]  __alloc_pages_slowpath+0x343/0x6f8
[  192.152817]  __alloc_pages_nodemask+0x1aa/0x1c0
[  192.152819]  handle_mm_fault+0x5c9/0xdb0
[  192.152821]  ? filemap_fdatawait+0x50/0x50
[  192.152824]  __do_page_fault+0x19c/0x460
[  192.152826]  ? __do_page_fault+0x460/0x460
[  192.152827]  do_page_fault+0x1a/0x20
[  192.152829]  common_exception+0x6c/0x72
[  192.152830] EIP: 0x804858f
[  192.152830] EFLAGS: 00010202 CPU: 0
[  192.152831] EAX: 02d8b000 EBX: 37689008 ECX: 3a414008 EDX: 00000000
[  192.152832] ESI: 7ff00000 EDI: 00000000 EBP: bfd2b608 ESP: bfd2b5d0
[  192.152834]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  192.152835] Code: c1 89 e5 e8 5e dd fb ff 0f 0b 55 89 e5 0f 0b 55 ba 70 82 7a c1 89 e5 e8 4a dd fb ff 0f 0b 55 ba 20 e0 78 c1 89 e5 e8 3b dd fb ff <0f> 0b 55 ba 88 70 7a c1 89 e5 e8 2c dd fb ff 0f 0b 55 ba 6c 81
[  192.152860] EIP: put_page_testzero.part.46+0xd/0xf SS:ESP: 0068:dde1bbec
[  192.152862] ---[ end trace fc4e4fddd132aaf1 ]---



As of 22ffb33f4620b502799877d4186502bfe20621ea:

[   77.872133] BUG: Bad page state in process a.out  pfn:1873a
[   77.872136] page:f729e110 count:0 mapcount:6 mapping:f1187224 index:0x0
[   77.872138] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
[   77.872141] raw: 19010019 f1187224 00000000 00000005 00000000 f729e124 f729e124 00000000
[   77.872141] raw: 00000000 00000000
[   77.872142] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[   77.872142] bad because of flags: 0x1(locked)
[   77.872143] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev pcspkr vmw_balloon sg vmw_vmci shpchp parport_pc parport i2c_piix4 ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix e1000 mptbase libata
[   77.872170] CPU: 6 PID: 1538 Comm: a.out Not tainted 4.11.0+ #277
[   77.872171] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   77.872172] Call Trace:
[   77.872179]  dump_stack+0x58/0x76
[   77.872183]  bad_page+0xbf/0x130
[   77.872185]  free_pages_check_bad+0x5b/0x5e
[   77.872186]  free_hot_cold_page+0x211/0x250
[   77.872188]  __put_page+0x30/0x40
[   77.872190]  try_to_unmap_one+0x375/0x550
[   77.872191]  rmap_walk_file+0x13c/0x270
[   77.872192]  rmap_walk+0x32/0x60
[   77.872193]  try_to_unmap+0x9d/0x120
[   77.872195]  ? page_remove_rmap+0x2c0/0x2c0
[   77.872195]  ? page_not_mapped+0x10/0x10
[   77.872196]  ? page_get_anon_vma+0x80/0x80
[   77.872198]  shrink_page_list+0x376/0xdf0
[   77.872201]  shrink_inactive_list+0x173/0x360
[   77.872203]  shrink_node_memcg+0x33a/0x720
[   77.872205]  shrink_node+0xbb/0x2e0
[   77.872207]  do_try_to_free_pages+0xb2/0x2a0
[   77.872209]  try_to_free_pages+0xf9/0x330
[   77.872211]  __alloc_pages_slowpath+0x343/0x6f8
[   77.872212]  __alloc_pages_nodemask+0x1aa/0x1c0
[   77.872214]  pagecache_get_page+0x56/0x250
[   77.872217]  ? common_exception+0x6c/0x72
[   77.872218]  grab_cache_page_write_begin+0x20/0x40
[   77.872221]  iomap_write_begin+0x6b/0xf0
[   77.872223]  ? iov_iter_fault_in_readable+0x7b/0xd0
[   77.872224]  iomap_write_actor+0xcc/0x1c0
[   77.872226]  ? iomap_write_end+0x70/0x70
[   77.872228]  iomap_apply+0x117/0x1a0
[   77.872230]  iomap_file_buffered_write+0x83/0xc0
[   77.872231]  ? iomap_write_end+0x70/0x70
[   77.872250]  xfs_file_buffered_aio_write+0x93/0x1c0 [xfs]
[   77.872264]  xfs_file_write_iter+0x77/0x150 [xfs]
[   77.872266]  ? __debug_check_no_obj_freed+0xed/0x1b0
[   77.872268]  __vfs_write+0xdf/0x140
[   77.872269]  vfs_write+0x96/0x190
[   77.872270]  SyS_write+0x44/0xa0
[   77.872272]  do_fast_syscall_32+0x86/0x130
[   77.872275]  entry_SYSENTER_32+0x4e/0x7c
[   77.872276] EIP: 0xb76fdda1
[   77.872276] EFLAGS: 00000246 CPU: 6
[   77.872277] EAX: ffffffda EBX: 00000003 ECX: 0804a060 EDX: 00001000
[   77.872278] ESI: bf863384 EDI: 00000000 EBP: bf8632e8 ESP: bf863298
[   77.872279]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   77.872280] Disabling lock debugging due to kernel taint
[   77.872284] page:f729e110 count:0 mapcount:0 mapping:f1187224 index:0x0
[   77.872285] flags: 0x19030078(uptodate|dirty|lru|active|mappedtodisk|reclaim)
[   77.872287] raw: 19030078 f1187224 00000000 ffffffff 00000000 f400c2d8 f400c2d8 00000000
[   77.872287] raw: 00000000 00000000
[   77.872288] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[   77.872293] ------------[ cut here ]------------
[   77.872294] kernel BUG at ./include/linux/mm.h:466!
[   77.872307] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   77.872307] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev pcspkr vmw_balloon sg vmw_vmci shpchp parport_pc parport i2c_piix4 ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix e1000 mptbase libata
[   77.872324] CPU: 6 PID: 1538 Comm: a.out Tainted: G    B           4.11.0+ #277
[   77.872324] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   77.872325] task: ef500a40 task.stack: ef562000
[   77.872327] EIP: put_page_testzero.part.46+0xd/0xf
[   77.872327] EFLAGS: 00010082 CPU: 6
[   77.872328] EAX: 00000000 EBX: f400c2c0 ECX: c1870e80 EDX: 00000002
[   77.872329] ESI: f729e124 EDI: 00000003 EBP: ef563a24 ESP: ef563a24
[   77.872329]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   77.872330] CR0: 80050033 CR2: 0804b05f CR3: 2fbc5000 CR4: 000406d0
[   77.872389] Call Trace:
[   77.872392]  putback_inactive_pages+0x384/0x3c0
[   77.872394]  shrink_inactive_list+0x193/0x360
[   77.872396]  shrink_node_memcg+0x33a/0x720
[   77.872398]  shrink_node+0xbb/0x2e0
[   77.872400]  do_try_to_free_pages+0xb2/0x2a0
[   77.872401]  try_to_free_pages+0xf9/0x330
[   77.872403]  __alloc_pages_slowpath+0x343/0x6f8
[   77.872405]  __alloc_pages_nodemask+0x1aa/0x1c0
[   77.872407]  pagecache_get_page+0x56/0x250
[   77.872408]  ? common_exception+0x6c/0x72
[   77.872409]  grab_cache_page_write_begin+0x20/0x40
[   77.872411]  iomap_write_begin+0x6b/0xf0
[   77.872412]  ? iov_iter_fault_in_readable+0x7b/0xd0
[   77.872413]  iomap_write_actor+0xcc/0x1c0
[   77.872415]  ? iomap_write_end+0x70/0x70
[   77.872416]  iomap_apply+0x117/0x1a0
[   77.872418]  iomap_file_buffered_write+0x83/0xc0
[   77.872420]  ? iomap_write_end+0x70/0x70
[   77.872433]  xfs_file_buffered_aio_write+0x93/0x1c0 [xfs]
[   77.872445]  xfs_file_write_iter+0x77/0x150 [xfs]
[   77.872446]  ? __debug_check_no_obj_freed+0xed/0x1b0
[   77.872447]  __vfs_write+0xdf/0x140
[   77.872448]  vfs_write+0x96/0x190
[   77.872449]  SyS_write+0x44/0xa0
[   77.872451]  do_fast_syscall_32+0x86/0x130
[   77.872453]  entry_SYSENTER_32+0x4e/0x7c
[   77.872453] EIP: 0xb76fdda1
[   77.872454] EFLAGS: 00000246 CPU: 6
[   77.872454] EAX: ffffffda EBX: 00000003 ECX: 0804a060 EDX: 00001000
[   77.872455] ESI: bf863384 EDI: 00000000 EBP: bf8632e8 ESP: bf863298
[   77.872456]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   77.872456] Code: c1 89 e5 e8 9e dd fb ff 0f 0b 55 89 e5 0f 0b 55 ba 70 82 7a c1 89 e5 e8 8a dd fb ff 0f 0b 55 ba 20 e0 78 c1 89 e5 e8 7b dd fb ff <0f> 0b 55 ba 88 70 7a c1 89 e5 e8 6c dd fb ff 0f 0b 55 ba 6c 81
[   77.872472] EIP: put_page_testzero.part.46+0xd/0xf SS:ESP: 0068:ef563a24
[   77.872474] ---[ end trace fac67653a2c4994f ]---



As of 18863d3a3f593f47b075b9f53ebf9228dc76cf72:

[  188.992549] BUG: Bad page state in process a.out  pfn:197ea
[  188.992551] page:f72c7c90 count:0 mapcount:12 mapping:f11b8ca4 index:0x0
[  188.992554] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
[  188.992557] raw: 19010019 f11b8ca4 00000000 0000000b 00000000 f72c7ca4 f72c7ca4 00000000
[  188.992557] raw: 00000000 00000000
[  188.992558] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[  188.992559] bad because of flags: 0x1(locked)
[  188.992559] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp pcspkr sg ppdev vmw_balloon parport_pc parport i2c_piix4 vmw_vmci shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ata_piix e1000 mptscsih libata mptbase
[  188.992624] CPU: 3 PID: 5140 Comm: a.out Not tainted 4.11.0+ #278
[  188.992625] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  188.992625] Call Trace:
[  188.992632]  dump_stack+0x58/0x76
[  188.992636]  bad_page+0xbf/0x130
[  188.992639]  free_pages_check_bad+0x5b/0x5e
[  188.992640]  free_hot_cold_page+0x211/0x250
[  188.992642]  __put_page+0x30/0x40
[  188.992643]  try_to_unmap_one+0x375/0x550
[  188.992645]  rmap_walk_file+0x13c/0x270
[  188.992646]  rmap_walk+0x32/0x60
[  188.992647]  try_to_unmap+0x9d/0x120
[  188.992648]  ? page_remove_rmap+0x2c0/0x2c0
[  188.992649]  ? page_not_mapped+0x10/0x10
[  188.992650]  ? page_get_anon_vma+0x80/0x80
[  188.992652]  shrink_page_list+0x376/0xdf0
[  188.992654]  shrink_inactive_list+0x173/0x360
[  188.992656]  shrink_node_memcg+0x33a/0x720
[  188.992659]  shrink_node+0xbb/0x2e0
[  188.992661]  do_try_to_free_pages+0xb2/0x2a0
[  188.992662]  try_to_free_pages+0xf9/0x330
[  188.992666]  ? schedule_timeout+0x142/0x200
[  188.992668]  __alloc_pages_slowpath+0x343/0x6f8
[  188.992669]  __alloc_pages_nodemask+0x1aa/0x1c0
[  188.992671]  handle_mm_fault+0x5c9/0xdb0
[  188.992673]  ? pick_next_task_fair+0x431/0x530
[  188.992676]  __do_page_fault+0x19c/0x460
[  188.992677]  ? __do_page_fault+0x460/0x460
[  188.992678]  do_page_fault+0x1a/0x20
[  188.992680]  common_exception+0x6c/0x72
[  188.992681] EIP: 0x804858f
[  188.992681] EFLAGS: 00010202 CPU: 3
[  188.992682] EAX: 0094c000 EBX: 37706008 ECX: 38052008 EDX: 00000000
[  188.992683] ESI: 7ff00000 EDI: 00000000 EBP: bfeac158 ESP: bfeac120
[  188.992684]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  188.992685] Disabling lock debugging due to kernel taint
[  188.992689] page:f72c7c90 count:0 mapcount:0 mapping:f11b8ca4 index:0x0
[  188.992691] flags: 0x19030078(uptodate|dirty|lru|active|mappedtodisk|reclaim)
[  188.992692] raw: 19030078 f11b8ca4 00000000 ffffffff 00000000 f400c2d8 f400c2d8 00000000
[  188.992693] raw: 00000000 00000000
[  188.992693] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
[  188.992698] ------------[ cut here ]------------
[  188.992699] kernel BUG at ./include/linux/mm.h:466!
[  188.992700] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[  188.992701] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp pcspkr sg ppdev vmw_balloon parport_pc parport i2c_piix4 vmw_vmci shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ata_piix e1000 mptscsih libata mptbase
[  188.992716] CPU: 3 PID: 5140 Comm: a.out Tainted: G    B           4.11.0+ #278
[  188.992716] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  188.992717] task: e4929440 task.stack: e49ee000
[  188.992719] EIP: put_page_testzero.part.46+0xd/0xf
[  188.992719] EFLAGS: 00010092 CPU: 3
[  188.992720] EAX: 00000000 EBX: f400c2c0 ECX: c1870e80 EDX: 00000002
[  188.992720] ESI: f72c7ca4 EDI: 00000003 EBP: e49efbec ESP: e49efbec
[  188.992721]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  188.992722] CR0: 80050033 CR2: 386b6008 CR3: 24a5d000 CR4: 000406d0
[  188.992781] Call Trace:
[  188.992784]  putback_inactive_pages+0x384/0x3c0
[  188.992786]  shrink_inactive_list+0x193/0x360
[  188.992788]  shrink_node_memcg+0x33a/0x720
[  188.992790]  shrink_node+0xbb/0x2e0
[  188.992791]  do_try_to_free_pages+0xb2/0x2a0
[  188.992793]  try_to_free_pages+0xf9/0x330
[  188.992795]  ? schedule_timeout+0x142/0x200
[  188.992797]  __alloc_pages_slowpath+0x343/0x6f8
[  188.992798]  __alloc_pages_nodemask+0x1aa/0x1c0
[  188.992800]  handle_mm_fault+0x5c9/0xdb0
[  188.992801]  ? pick_next_task_fair+0x431/0x530
[  188.992803]  __do_page_fault+0x19c/0x460
[  188.992804]  ? __do_page_fault+0x460/0x460
[  188.992805]  do_page_fault+0x1a/0x20
[  188.992806]  common_exception+0x6c/0x72
[  188.992807] EIP: 0x804858f
[  188.992807] EFLAGS: 00010202 CPU: 3
[  188.992808] EAX: 0094c000 EBX: 37706008 ECX: 38052008 EDX: 00000000
[  188.992809] ESI: 7ff00000 EDI: 00000000 EBP: bfeac158 ESP: bfeac120
[  188.992809]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  188.992810] Code: c1 89 e5 e8 9e dd fb ff 0f 0b 55 89 e5 0f 0b 55 ba 70 82 7a c1 89 e5 e8 8a dd fb ff 0f 0b 55 ba 20 e0 78 c1 89 e5 e8 7b dd fb ff <0f> 0b 55 ba 88 70 7a c1 89 e5 e8 6c dd fb ff 0f 0b 55 ba 6c 81
[  188.992826] EIP: put_page_testzero.part.46+0xd/0xf SS:ESP: 0068:e49efbec
[  188.992827] ---[ end trace 16134a8679cd7c8c ]---



As of c24f386c60b2269d532a23e70939ed8ce55d7005:

[   56.841712] BUG: unable to handle kernel paging request at 32eba010
[   56.841718] IP: page_remove_rmap+0x190/0x2c0
[   56.841719] *pde = 00000000 
[   56.841720] 
[   56.841722] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[   56.841723] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev vmw_balloon pcspkr sg shpchp i2c_piix4 vmw_vmci parport_pc parport ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix e1000 mptbase libata
** 361 printk messages dropped ** [   56.843217] BUG: unable to handle kernel paging request at 00737d5c
** 2283 printk messages dropped ** [   56.849961]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
** 1563 printk messages dropped ** [   56.854562] BUG: unable to handle kernel paging request at 00737d5c
** 2110 printk messages dropped ** [   56.860720] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev vmw_balloon pcspkr sg shpchp i2c_piix4 vmw_vmci parport_pc parport ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix e1000 mptbase libata
** 11037 printk messages dropped ** [   56.885507] EFLAGS: 00010202 CPU: 2
** 1332 printk messages dropped ** [   56.889324] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0737f30
** 1975 printk messages dropped ** [   56.895432] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0737f30
** 2201 printk messages dropped ** [   56.901915] EIP: 0x804858f
** 1357 printk messages dropped ** [   56.905721] ---[ end trace 66e5871b6d0ec353 ]---



As of d44d363f65780f2ac2ec672164555af54896d40d:

[  157.814036] BUG: unable to handle kernel paging request at f6c8f9a4
[  157.814041] IP: page_remove_rmap+0x7/0x2c0
[  157.814042] *pde = 3732c067 
[  157.814043] *pte = 36c8f062 
[  157.814044] 
[  157.814045] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  157.814046] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg ppdev vmw_balloon pcspkr shpchp vmw_vmci i2c_piix4 parport_pc parport ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ata_piix e1000 mptbase libata
[  157.814074] CPU: 6 PID: 3979 Comm: a.out Not tainted 4.11.0+ #280
[  157.814074] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  157.814075] task: e8456440 task.stack: e8502000
[  157.814077] EIP: page_remove_rmap+0x7/0x2c0
[  157.814077] EFLAGS: 00010246 CPU: 6
[  157.814078] EAX: f6c8f990 EBX: f6c8f990 ECX: 00000001 EDX: 00000000
[  157.814079] ESI: f71511b8 EDI: 000006d9 EBP: e85038e0 ESP: e85038d8
[  157.814080]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  157.814081] CR0: 80050033 CR2: f6c8f9a4 CR3: 284b0000 CR4: 000406d0
[  157.814138] Call Trace:
[  157.814141]  try_to_unmap_one+0x200/0x500
[  157.814143]  rmap_walk_file+0x13c/0x270
[  157.814144]  rmap_walk+0x32/0x60
[  157.814145]  try_to_unmap+0xb5/0x150
[  157.814146]  ? page_remove_rmap+0x2c0/0x2c0
[  157.814147]  ? page_not_mapped+0x10/0x10
[  157.814148]  ? page_get_anon_vma+0x80/0x80
[  157.814151]  shrink_page_list+0x368/0xce0
[  157.814153]  shrink_inactive_list+0x173/0x360
[  157.814155]  shrink_node_memcg+0x33a/0x720
[  157.814157]  shrink_node+0xb3/0x2e0
[  157.814159]  do_try_to_free_pages+0xb2/0x290
[  157.814161]  try_to_free_pages+0xea/0x310
[  157.814164]  __alloc_pages_slowpath+0x340/0x6f5
[  157.814184]  ? xfs_trans_free+0x59/0x60 [xfs]
[  157.814185]  __alloc_pages_nodemask+0x19e/0x1b0
[  157.814188]  pagecache_get_page+0x56/0x250
[  157.814203]  ? xfs_iunlock+0xac/0x160 [xfs]
[  157.814204]  grab_cache_page_write_begin+0x20/0x40
[  157.814207]  iomap_write_begin+0x6b/0xf0
[  157.814208]  iomap_write_actor+0xcc/0x1c0
[  157.814210]  ? iomap_write_end+0x70/0x70
[  157.814211]  iomap_apply+0x117/0x1a0
[  157.814213]  iomap_file_buffered_write+0x83/0xc0
[  157.814214]  ? iomap_write_end+0x70/0x70
[  157.814229]  xfs_file_buffered_aio_write+0x93/0x1c0 [xfs]
[  157.814230]  ? filemap_map_pages+0x34b/0x3c0
[  157.814243]  xfs_file_write_iter+0x77/0x150 [xfs]
[  157.814255]  ? xfs_filemap_fault+0x36/0x40 [xfs]
[  157.814256]  __vfs_write+0xdf/0x140
[  157.814258]  vfs_write+0x96/0x190
[  157.814259]  SyS_write+0x44/0xa0
[  157.814261]  do_fast_syscall_32+0x86/0x130
[  157.814263]  entry_SYSENTER_32+0x4e/0x7c
[  157.814264] EIP: 0xb7751da1
[  157.814265] EFLAGS: 00000246 CPU: 6
[  157.814265] EAX: ffffffda EBX: 00000003 ECX: 0804a060 EDX: 00001000
[  157.814266] ESI: bf989bc4 EDI: 00000000 EBP: bf989b28 ESP: bf989ad8
[  157.814267]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  157.814268] Code: 00 83 e8 01 e9 dc fe ff ff ba b8 73 7a c1 89 d8 e8 af fa fe ff 0f 0b 83 e8 01 eb 8e 90 8d b4 26 00 00 00 00 55 89 e5 56 53 89 c3 <8b> 40 14 a8 01 0f 85 a4 01 00 00 89 d8 f6 40 04 01 74 5e 84 d2
[  157.814283] EIP: page_remove_rmap+0x7/0x2c0 SS:ESP: 0068:e85038d8
[  157.814284] CR2: 00000000f6c8f9a4
[  157.814286] ---[ end trace a941a5b48c8262c4 ]---



As of a128ca71fb29ed4444b80f38a0148b468826e19b:

[   54.943695] BUG: unable to handle kernel paging request at c1147f4b
[   54.943704] IP: _raw_spin_lock_irqsave+0x1c/0x40
[   54.943705] *pde = 01adc063 
[   54.943706] *pte = 01147161 
[   54.943707] 
[   54.943709] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
[   54.943710] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg ppdev pcspkr vmw_balloon vmw_vmci i2c_piix4 parport_pc parport shpchp ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
** 4557 printk messages dropped ** [   54.959191] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2357 printk messages dropped ** [   54.966297] ---[ end trace 738da708534ed3b1 ]---
** 1530 printk messages dropped ** [   54.970986] EFLAGS: 00010202 CPU: 3
** 1356 printk messages dropped ** [   54.975010] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0e35f30
** 2246 printk messages dropped ** [   54.981496] EAX: e0e35d04 EBX: 00000009 ECX: e0cfc640 EDX: c1074c33
** 2251 printk messages dropped ** [   54.987786] IP: blk_flush_plug_list+0x54/0x210
** 1526 printk messages dropped ** [   54.992041] EIP: 0x804858f
** 1285 printk messages dropped ** [   54.995936] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2452 printk messages dropped ** [   55.003072] Call Trace:
** 1290 printk messages dropped ** [   55.006821] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2456 printk messages dropped ** [   55.014067]  rewind_stack_do_exit+0x11/0x13
** 1514 printk messages dropped ** [   55.018507] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0e35f30
** 2336 printk messages dropped ** [   55.025302] ESI: 7ff00000 EDI: 00000000 EBP: bf9bdce8 ESP: bf9bdcb0
** 2296 printk messages dropped ** [   55.032024] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2457 printk messages dropped ** [   55.039223] EAX: 00218000 EBX: 37701008 ECX: 37919008 EDX: 00000000
** 2339 printk messages dropped ** [   55.046204] EAX: 00218000 EBX: 37701008 ECX: 37919008 EDX: 00000000
** 2377 printk messages dropped ** [   55.053003] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2573 printk messages dropped ** [   55.060515] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2631 printk messages dropped ** [   55.068308] ESI: e0e36000 EDI: e0cfc640 EBP: e0e35fac ESP: e0e35f70
** 2483 printk messages dropped ** [   55.075574] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0e35f30
** 2476 printk messages dropped ** [   55.082895] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
** 3092 printk messages dropped ** [   55.092077] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2703 printk messages dropped ** [   55.100031] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2677 printk messages dropped ** [   55.107930] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2704 printk messages dropped ** [   55.115891] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
** 3133 printk messages dropped ** [   55.124900] EFLAGS: 00010202 CPU: 3
** 1518 printk messages dropped ** [   55.129366] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2721 printk messages dropped ** [   55.137262] ---[ end trace 738da708534edc79 ]---
[   54.943695] BUG: unable to handle kernel paging request at c1147f4b
[   54.943704] IP: _raw_spin_lock_irqsave+0x1c/0x40
[   54.943705] *pde = 01adc063 
[   54.943706] *pte = 01147161 
[   54.943707] 
[   54.943709] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
[   54.943710] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg ppdev pcspkr vmw_balloon vmw_vmci i2c_piix4 parport_pc parport shpchp ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
** 4557 printk messages dropped ** [   54.959191] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2357 printk messages dropped ** [   54.966297] ---[ end trace 738da708534ed3b1 ]---
** 1530 printk messages dropped ** [   54.970986] EFLAGS: 00010202 CPU: 3
** 1356 printk messages dropped ** [   54.975010] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0e35f30
** 2246 printk messages dropped ** [   54.981496] EAX: e0e35d04 EBX: 00000009 ECX: e0cfc640 EDX: c1074c33
** 2251 printk messages dropped ** [   54.987786] IP: blk_flush_plug_list+0x54/0x210
** 1526 printk messages dropped ** [   54.992041] EIP: 0x804858f
** 1285 printk messages dropped ** [   54.995936] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2452 printk messages dropped ** [   55.003072] Call Trace:
** 1290 printk messages dropped ** [   55.006821] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2456 printk messages dropped ** [   55.014067]  rewind_stack_do_exit+0x11/0x13
** 1514 printk messages dropped ** [   55.018507] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0e35f30
** 2336 printk messages dropped ** [   55.025302] ESI: 7ff00000 EDI: 00000000 EBP: bf9bdce8 ESP: bf9bdcb0
** 2296 printk messages dropped ** [   55.032024] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2457 printk messages dropped ** [   55.039223] EAX: 00218000 EBX: 37701008 ECX: 37919008 EDX: 00000000
** 2339 printk messages dropped ** [   55.046204] EAX: 00218000 EBX: 37701008 ECX: 37919008 EDX: 00000000
** 2377 printk messages dropped ** [   55.053003] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2573 printk messages dropped ** [   55.060515] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2631 printk messages dropped ** [   55.068308] ESI: e0e36000 EDI: e0cfc640 EBP: e0e35fac ESP: e0e35f70
** 2483 printk messages dropped ** [   55.075574] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:e0e35f30
** 2476 printk messages dropped ** [   55.082895] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
** 3092 printk messages dropped ** [   55.092077] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2703 printk messages dropped ** [   55.100031] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2677 printk messages dropped ** [   55.107930] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2704 printk messages dropped ** [   55.115891] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
** 3133 printk messages dropped ** [   55.124900] EFLAGS: 00010202 CPU: 3
** 1518 printk messages dropped ** [   55.129366] CPU: 3 PID: 6387 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2721 printk messages dropped ** [   55.137262] ---[ end trace 738da708534edc79 ]---



As of a128ca71fb29ed4444b80f38a0148b468826e19b:

[   65.347528] BUG: unable to handle kernel paging request at 330de01a
[   65.347534] IP: page_remove_rmap+0x14/0x2c0
[   65.347535] *pde = 00000000 
[   65.347536] 
[   65.347538] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   65.347539] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp pcspkr vmw_balloon sg ppdev shpchp vmw_vmci parport_pc i2c_piix4 parport ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi ata_piix mptscsih e1000 mptbase libata
** 3288 printk messages dropped ** [   65.362121] CR0: 80050033 CR2: 008b7d5c CR3: 2e67c000 CR4: 000406d0
** 2299 printk messages dropped ** [   65.368742] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:ee8b7f30
** 2345 printk messages dropped ** [   65.375469] CPU: 1 PID: 1883 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2487 printk messages dropped ** [   65.382562]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
** 1300 printk messages dropped ** [   65.386360] Code: 55 d4 88 55 db 89 5d e8 89 5d ec 89 45 dc 90 8b 47 10 39 45 dc 74 52 8b 47 10 39 45 dc 74 20 8b 4f 10 8b 45 e8 8b 57 14 89 4d e8 <89> 59 04 89 02 89 50 04 8b 45 dc 89 47 10 89 47 14 8d 76 00 8b
** 4576 printk messages dropped ** [   65.400878] EIP: blk_flush_plug_list+0x54/0x210 SS:ESP: 0068:ee8b7f30
** 2499 printk messages dropped ** [   65.408166] WARNING: CPU: 1 PID: 1883 at kernel/exit.c:785 do_exit+0x3a/0xa30
** 2627 printk messages dropped ** [   65.415842] CPU: 1 PID: 1883 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2669 printk messages dropped ** [   65.424749]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
** 1749 printk messages dropped ** [   65.429863] CPU: 1 PID: 1883 Comm: a.out Tainted: G      D W       4.11.0+ #281
** 2640 printk messages dropped ** [   65.437531] ESI: 7ff00000 EDI: 00000000 EBP: bfbb8f38 ESP: bfbb8f00
** 2503 printk messages dropped ** [   65.444809] 
** 1242 printk messages dropped ** [   65.448427] ---[ end trace 2b10bcdd7b092bf2 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
