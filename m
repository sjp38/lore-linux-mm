Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id B39886B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 13:40:34 -0400 (EDT)
Date: Wed, 30 May 2012 13:40:30 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mm list corruption/hard lockup.
Message-ID: <20120530174030.GA21799@redhat.com>
References: <20120530165358.GA15856@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120530165358.GA15856@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, May 30, 2012 at 12:53:58PM -0400, Dave Jones wrote:
 > Just hit this with Linus current tree (4523e1458566a0e8ecfaff90f380dd23acc44d27)

rebooted, restarted the test. Got a different trace, and then another version of the first.

[ 2506.363272] WARNING: at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
[ 2506.365342] list_del corruption. prev->next should be ffffea00044574a0, but was ffffea0004b02020
[ 2506.366254] Modules linked in: tun dccp_ipv4 dccp fuse ipt_ULOG binfmt_misc nfnetlink sctp libcrc32c caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode pcspkr usb_debug e1000e i2c_i801 lpc_ich mfd_core nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
[ 2506.369813] Pid: 1193, comm: trinity-child5 Not tainted 3.4.0+ #37
[ 2506.370732] Call Trace:
[ 2506.371656]  [<ffffffff81048fdf>] warn_slowpath_common+0x7f/0xc0
[ 2506.372595]  [<ffffffff810490d6>] warn_slowpath_fmt+0x46/0x50
[ 2506.373608]  [<ffffffff813253a1>] __list_del_entry+0xa1/0xd0
[ 2506.374640]  [<ffffffff813253e1>] list_del+0x11/0x40
[ 2506.375634]  [<ffffffff811480f6>] free_pcppages_bulk+0x286/0x4e0
[ 2506.376631]  [<ffffffff81148ad3>] free_hot_cold_page+0x163/0x1c0
[ 2506.377633]  [<ffffffff81148d86>] free_hot_cold_page_list+0x66/0x190
[ 2506.378639]  [<ffffffff8114e622>] release_pages+0x1e2/0x220
[ 2506.379654]  [<ffffffff8117d8fd>] free_pages_and_swap_cache+0xad/0xd0
[ 2506.380677]  [<ffffffff8116884c>] tlb_flush_mmu+0x6c/0x90
[ 2506.381704]  [<ffffffff81168884>] tlb_finish_mmu+0x14/0x40
[ 2506.382736]  [<ffffffff8116f6cc>] unmap_region+0xcc/0x110
[ 2506.383772]  [<ffffffff81170d76>] do_munmap+0x2b6/0x410
[ 2506.384805]  [<ffffffff81174273>] do_mremap+0x103/0x560
[ 2506.385837]  [<ffffffff81656a25>] ? down_write+0x95/0xb0
[ 2506.386874]  [<ffffffff8117471d>] ? sys_mremap+0x4d/0xa0
[ 2506.387918]  [<ffffffff81174732>] sys_mremap+0x62/0xa0
[ 2506.388966]  [<ffffffff816613d2>] system_call_fastpath+0x16/0x1b
[ 2506.390023] ---[ end trace 2ea20e648e30ea44 ]---
[ 2506.391086] ------------[ cut here ]------------
[ 2506.392796] WARNING: at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
[ 2506.396587] list_del corruption. prev->next should be ffffea0004b00ee0, but was ffffea0004422260
[ 2506.398276] Modules linked in: tun dccp_ipv4 dccp fuse ipt_ULOG binfmt_misc nfnetlink sctp libcrc32c caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode pcspkr usb_debug e1000e i2c_i801 lpc_ich mfd_core nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]
[ 2506.405163] Pid: 550, comm: trinity-child3 Tainted: G        W    3.4.0+ #37
[ 2506.406878] Call Trace:
[ 2506.408547]  [<ffffffff81048fdf>] warn_slowpath_common+0x7f/0xc0
[ 2506.410788]  [<ffffffff810490d6>] warn_slowpath_fmt+0x46/0x50
[ 2506.412429]  [<ffffffff813253a1>] __list_del_entry+0xa1/0xd0
[ 2506.414026]  [<ffffffff811457b9>] move_freepages_block+0x159/0x190
[ 2506.415803]  [<ffffffff811658b3>] suitable_migration_target.isra.15+0x1b3/0x1d0
[ 2506.417866]  [<ffffffff81165afe>] compaction_alloc+0x22e/0x2f0
[ 2506.419380]  [<ffffffff81198227>] migrate_pages+0xc7/0x540
[ 2506.421346]  [<ffffffff811658d0>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
[ 2506.423280]  [<ffffffff81166856>] compact_zone+0x216/0x480
[ 2506.425163]  [<ffffffff810b7382>] ? mark_held_locks+0xb2/0x130
[ 2506.426998]  [<ffffffff81166d9d>] compact_zone_order+0x8d/0xd0
[ 2506.428628]  [<ffffffff81166ea9>] try_to_compact_pages+0xc9/0x140
[ 2506.430458]  [<ffffffff8164ea81>] __alloc_pages_direct_compact+0xaa/0x1d0
[ 2506.431827]  [<ffffffff81149e2b>] __alloc_pages_nodemask+0x60b/0xab0
[ 2506.433169]  [<ffffffff810b1208>] ? trace_hardirqs_off_caller+0x28/0xc0
[ 2506.434515]  [<ffffffff810b4b00>] ? __lock_acquire+0x2c0/0x1aa0
[ 2506.435852]  [<ffffffff81189bb6>] alloc_pages_vma+0xb6/0x190
[ 2506.437181]  [<ffffffff8119cca3>] do_huge_pmd_anonymous_page+0x133/0x310
[ 2506.438519]  [<ffffffff8116bfb2>] handle_mm_fault+0x242/0x2e0
[ 2506.440294]  [<ffffffff8116c262>] __get_user_pages+0x142/0x560
[ 2506.441634]  [<ffffffff81171928>] ? mmap_region+0x3f8/0x630
[ 2506.442982]  [<ffffffff81317b3d>] ? rb_insert_color+0xad/0x150
[ 2506.444332]  [<ffffffff8116c732>] get_user_pages+0x52/0x60
[ 2506.445673]  [<ffffffff8116d622>] make_pages_present+0x92/0xc0
[ 2506.447026]  [<ffffffff811718d6>] mmap_region+0x3a6/0x630
[ 2506.448368]  [<ffffffff81050a6c>] ? do_setitimer+0x1cc/0x310
[ 2506.449707]  [<ffffffff81171ebd>] do_mmap_pgoff+0x35d/0x3b0
[ 2506.451043]  [<ffffffff81171f76>] ? sys_mmap_pgoff+0x66/0x240
[ 2506.452353]  [<ffffffff81171f94>] sys_mmap_pgoff+0x84/0x240
[ 2506.453628]  [<ffffffff8131eeee>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 2506.454874]  [<ffffffff81006ca2>] sys_mmap+0x22/0x30
[ 2506.456330]  [<ffffffff816613d2>] system_call_fastpath+0x16/0x1b
[ 2506.457879] ---[ end trace 2ea20e648e30ea45 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
