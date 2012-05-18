Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 1C2FF6B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 13:19:37 -0400 (EDT)
Date: Fri, 18 May 2012 13:19:31 -0400
From: Dave Jones <davej@redhat.com>
Subject: 3.4-rc7: kernel BUG at mm/mempolicy.c:1564!
Message-ID: <20120518171931.GA6131@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

kernel BUG at mm/mempolicy.c:1564!
invalid opcode: 0000 [#1] PREEMPT SMP 
CPU 4 
Modules linked in: dccp_ipv6 dccp_ipv4 dccp nfnetlink tun ipt_ULOG ip6_queue sctp libcrc32c binfmt_misc ip_queue caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose ax25 x25 atm appletalk ipx p8022 psnap llc p8023 lockd ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables crc32c_intel ghash_clmulni_intel usb_debug microcode serio_raw i2c_i801 pcspkr iTCO_wdt e1000e iTCO_vendor_support sunrpc i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]

Pid: 1063, comm: trinity Not tainted 3.4.0-rc7+ #11 Intel Corporation 2012 Client Platform/Emerald Lake 2
RIP: 0010:[<ffffffff8118176e>]  [<ffffffff8118176e>] policy_zonelist+0x1e/0xa0
RSP: 0000:ffff88014209b878  EFLAGS: 00010206
RAX: 0000000000006b6b RBX: 00000000000200da RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff88014209b9e0 RDI: 00000000000200da
RBP: ffff88014209b888 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000001 R12: ffff88014209b9e0
R13: ffff88013c628000 R14: 0000000000000000 R15: 0000000000000000
FS:  00007f2c52fb8700(0000) GS:ffff880148400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f2c52fbf024 CR3: 000000013ca0c000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity (pid: 1063, threadinfo ffff88014209a000, task ffff88013c628000)
Stack:
 ffff88014209b898 00000000000200da ffff88014209b908 ffffffff81184e64
 00000000000577c0 0000000000000000 ffff88013c628000 ffff88013c628000
 ffff88013c628000 0000000000000000 ffff88014209bae8 0000000082303b60
Call Trace:
 [<ffffffff81184e64>] alloc_pages_vma+0x84/0x190
 [<ffffffff811783eb>] read_swap_cache_async+0x13b/0x230
 [<ffffffff81185a64>] ? mpol_shared_policy_lookup+0x64/0x80
 [<ffffffff8117856e>] swapin_readahead+0x8e/0xd0
 [<ffffffff81155c84>] shmem_swapin+0x74/0x90
 [<ffffffff8113cc25>] ? find_get_page+0x105/0x260
 [<ffffffff8163d7ad>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8113cc42>] ? find_get_page+0x122/0x260
 [<ffffffff8113cb20>] ? find_get_pages_tag+0x330/0x330
 [<ffffffff81157ea8>] shmem_getpage_gfp+0x3c8/0x620
 [<ffffffff81158fdf>] shmem_fault+0x4f/0xa0
 [<ffffffff812a056e>] shm_fault+0x1e/0x20
 [<ffffffff81162f91>] __do_fault+0x71/0x510
 [<ffffffff81165a64>] handle_pte_fault+0x84/0xa10
 [<ffffffff8119c850>] ? mem_cgroup_count_vm_event+0xe0/0x1e0
 [<ffffffff8163d7ad>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff811666f2>] handle_mm_fault+0x1c2/0x2c0
 [<ffffffff8163d002>] do_page_fault+0x152/0x570
 [<ffffffff8104d75c>] ? do_wait+0x12c/0x370
 [<ffffffff812fee7d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff8163a1ef>] page_fault+0x1f/0x30
Code: 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 0f b7 46 04 66 83 f8 01 74 08 66 83 f8 02 74 42 <0f> 0b 89 fb 81 e3 00 00 04 00 f6 46 06 02 75 04 0f bf 56 08 31 
RIP  [<ffffffff8118176e>] policy_zonelist+0x1e/0xa0
 RSP <ffff88014209b878>
---[ end trace af5aef56428c20d1 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
