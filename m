Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 09C7D6B005D
	for <linux-mm@kvack.org>; Wed, 30 May 2012 12:33:22 -0400 (EDT)
Date: Wed, 30 May 2012 12:33:17 -0400
From: Dave Jones <davej@redhat.com>
Subject: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120530163317.GA13189@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

Just saw this on Linus tree as of 731a7378b81c2f5fa88ca1ae20b83d548d5613dc


------------[ cut here ]------------
WARNING: at mm/page-writeback.c:1990 __set_page_dirty_nobuffers+0x13a/0x170()
Hardware name:         
Modules linked in: ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_CHECKSUM iptable_mangle bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables snd_emu10k1 snd_util_mem snd_ac97_codec ac97_bus snd_hwdep snd_rawmidi snd_seq_device snd_pcm microcode snd_page_alloc pcspkr snd_timer snd lpc_ich i2c_i801 mfd_core e1000e soundcore vhost_net tun macvtap macvlan kvm_intel nfsd kvm nfs_acl auth_rpcgss lockd sunrpc btrfs libcrc32c zlib_deflate firewire_ohci firewire_core sata_sil crc_itu_t floppy radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded: scsi_wait_scan]
Pid: 35, comm: khugepaged Not tainted 3.4.0+ #75
Call Trace:
 [<ffffffff8104897f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff810489da>] warn_slowpath_null+0x1a/0x20
 [<ffffffff81146bda>] __set_page_dirty_nobuffers+0x13a/0x170
 [<ffffffff81193322>] migrate_page_copy+0x1e2/0x260
 [<ffffffff811933fb>] migrate_page+0x5b/0x70
 [<ffffffff811934b5>] move_to_new_page+0xa5/0x260
 [<ffffffff81193ca8>] migrate_pages+0x4c8/0x540
 [<ffffffff811610d0>] ? suitable_migration_target.isra.15+0x1d0/0x1d0
 [<ffffffff81162056>] compact_zone+0x216/0x480
 [<ffffffff81321ad8>] ? debug_check_no_obj_freed+0x88/0x210
 [<ffffffff8116259d>] compact_zone_order+0x8d/0xd0
 [<ffffffff811626a9>] try_to_compact_pages+0xc9/0x140
 [<ffffffff81649f4e>] __alloc_pages_direct_compact+0xaa/0x1d0
 [<ffffffff8114562b>] __alloc_pages_nodemask+0x60b/0xab0
 [<ffffffff81321bbc>] ? debug_check_no_obj_freed+0x16c/0x210
 [<ffffffff81185236>] alloc_pages_vma+0xb6/0x190
 [<ffffffff81195d8d>] khugepaged+0x95d/0x1570
 [<ffffffff81073350>] ? wake_up_bit+0x40/0x40
 [<ffffffff81195430>] ? collect_mm_slot+0xa0/0xa0
 [<ffffffff81072c37>] kthread+0xb7/0xc0
 [<ffffffff8165dc14>] kernel_thread_helper+0x4/0x10
 [<ffffffff8165511d>] ? retint_restore_args+0xe/0xe
 [<ffffffff81072b80>] ? flush_kthread_worker+0x190/0x190
 [<ffffffff8165dc10>] ? gs_change+0xb/0xb
---[ end trace 4324bd0bca27f6f0 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
