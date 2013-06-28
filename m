Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A929F6B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 04:39:47 -0400 (EDT)
Date: Fri, 28 Jun 2013 10:39:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130628083943.GA32747@dhcp22.suse.cz>
References: <20130617223004.GB2538@localhost.localdomain>
 <20130618024623.GP29338@dastard>
 <20130618063104.GB20528@localhost.localdomain>
 <20130618082414.GC13677@dhcp22.suse.cz>
 <20130618104443.GH13677@dhcp22.suse.cz>
 <20130618135025.GK13677@dhcp22.suse.cz>
 <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130627145411.GA24206@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

I have just triggered this one.

[37955.354041] BUG: unable to handle kernel paging request at 000000572ead7838
[37955.356032] IP: [<ffffffff81127e5b>] list_lru_walk_node+0xab/0x140
[37955.364062] PGD 2bf0a067 PUD 0 
[37955.364062] Oops: 0000 [#1] SMP 
[37955.364062] Modules linked in: edd nfsv3 nfs_acl nfs fscache lockd sunrpc af_packet bridge stp llc cpufreq_conservative cpufreq_userspace cpufreq_powersave fuse xfs libcrc32c loop dm_mod tg3 ptp powernow_k8 pps_core e1000 kvm_amd shpchp kvm edac_core i2c_amd756 pci_hotplug i2c_amd8111 sg edac_mce_amd amd_rng k8temp sr_mod pcspkr cdrom serio_raw button ohci_hcd ehci_hcd usbcore usb_common processor thermal_sys scsi_dh_emc scsi_dh_rdac scsi_dh_hp_sw scsi_dh ata_generic sata_sil pata_amd
[37955.364062] CPU 3 
[37955.364062] Pid: 3351, comm: as Not tainted 3.9.0mmotm+ #1490 AMD A8440/WARTHOG
[37955.364062] RIP: 0010:[<ffffffff81127e5b>]  [<ffffffff81127e5b>] list_lru_walk_node+0xab/0x140
[37955.364062] RSP: 0000:ffff8800374af7b8  EFLAGS: 00010286
[37955.364062] RAX: 0000000000000106 RBX: ffff88002ead7838 RCX: ffff8800374af830
[37955.364062] RDX: 0000000000000107 RSI: ffff88001d250dc0 RDI: ffff88002ead77d0
[37955.364062] RBP: ffff8800374af818 R08: 0000000000000000 R09: ffff88001ffeafc0
[37955.364062] R10: 0000000000000002 R11: 0000000000000000 R12: ffff88001d250dc0
[37955.364062] R13: 00000000000000a0 R14: 000000572ead7838 R15: ffff88001d250dc8
[37955.364062] FS:  00002aaaaaadb100(0000) GS:ffff88003fd00000(0000) knlGS:0000000000000000
[37955.364062] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[37955.364062] CR2: 000000572ead7838 CR3: 0000000036f61000 CR4: 00000000000007e0
[37955.364062] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[37955.364062] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[37955.364062] Process as (pid: 3351, threadinfo ffff8800374ae000, task ffff880036d665c0)
[37955.364062] Stack:
[37955.364062]  ffff88001da3e700 ffff8800374af830 ffff8800374af838 ffffffff811846d0
[37955.364062]  0000000000000000 ffff88001ce75c48 01ff8800374af838 ffff8800374af838
[37955.364062]  0000000000000000 ffff88001ce75800 ffff8800374afa08 0000000000001014
[37955.364062] Call Trace:
[37955.364062]  [<ffffffff811846d0>] ? insert_inode_locked+0x160/0x160
[37955.364062]  [<ffffffff8118496c>] prune_icache_sb+0x3c/0x60
[37955.364062]  [<ffffffff8116dcbe>] super_cache_scan+0x12e/0x1b0
[37955.364062]  [<ffffffff8111354a>] shrink_slab_node+0x13a/0x250
[37955.364062]  [<ffffffff8111671b>] shrink_slab+0xab/0x120
[37955.364062]  [<ffffffff81117944>] do_try_to_free_pages+0x264/0x360
[37955.364062]  [<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[37955.364062]  [<ffffffff81001974>] ? __switch_to+0x1b4/0x550
[37955.364062]  [<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[37955.364062]  [<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[37955.364062]  [<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[37955.364062]  [<ffffffff81129ebb>] do_anonymous_page+0x16b/0x350
[37955.364062]  [<ffffffff8112f9c5>] handle_pte_fault+0x235/0x240
[37955.364062]  [<ffffffff8107b8b0>] ? set_next_entity+0xb0/0xd0
[37955.364062]  [<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[37955.364062]  [<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[37955.364062]  [<ffffffff8116a8a8>] ? fsnotify_access+0x68/0x80
[37955.364062]  [<ffffffff8116b0b8>] ? vfs_read+0xd8/0x130
[37955.364062]  [<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[37955.364062]  [<ffffffff8157b348>] page_fault+0x28/0x30
[37955.364062] Code: 44 24 18 0f 84 87 00 00 00 49 83 7c 24 18 00 78 7b 49 83 c5 01 48 8b 4d a8 48 8b 11 48 8d 42 ff 48 85 d2 48 89 01 74 78 4d 39 f7 <49> 8b 06 4c 89 f3 74 6d 49 89 c6 eb a6 0f 1f 84 00 00 00 00 00 
[37955.364062] RIP  [<ffffffff81127e5b>] list_lru_walk_node+0xab/0x140

ffffffff81127e0e:       48 8b 55 b0             mov    -0x50(%rbp),%rdx
ffffffff81127e12:       4c 89 e6                mov    %r12,%rsi
ffffffff81127e15:       48 89 df                mov    %rbx,%rdi
ffffffff81127e18:       ff 55 b8                callq  *-0x48(%rbp)		# isolate(item, &nlru->lock, cb_arg)
ffffffff81127e1b:       83 f8 01                cmp    $0x1,%eax
ffffffff81127e1e:       74 78                   je     ffffffff81127e98 <list_lru_walk_node+0xe8>
ffffffff81127e20:       73 4e                   jae    ffffffff81127e70 <list_lru_walk_node+0xc0>
[...]
ffffffff81127e45:       48 8b 4d a8             mov    -0x58(%rbp),%rcx		# LRU_ROTATE:
ffffffff81127e49:       48 8b 11                mov    (%rcx),%rdx
ffffffff81127e4c:       48 8d 42 ff             lea    -0x1(%rdx),%rax	
ffffffff81127e50:       48 85 d2                test   %rdx,%rdx		# if ((*nr_to_walk)-- == 0)
ffffffff81127e53:       48 89 01                mov    %rax,(%rcx)
ffffffff81127e56:       74 78                   je     ffffffff81127ed0 <list_lru_walk_node+0x120>
ffffffff81127e58:       4d 39 f7                cmp    %r14,%r15
ffffffff81127e5b:       49 8b 06                mov    (%r14),%rax		<<< BANG
ffffffff81127e5e:       4c 89 f3                mov    %r14,%rbx
ffffffff81127e61:       74 6d                   je     ffffffff81127ed0 <list_lru_walk_node+0x120>
ffffffff81127e63:       49 89 c6                mov    %rax,%r14
ffffffff81127e66:       eb a6                   jmp    ffffffff81127e0e <list_lru_walk_node+0x5e>
[...]
ffffffff81127e70:       83 f8 02                cmp    $0x2,%eax
ffffffff81127e73:       74 d0                   je     ffffffff81127e45 <list_lru_walk_node+0x95>
ffffffff81127e75:       83 f8 03                cmp    $0x3,%eax
ffffffff81127e78:       74 06                   je     ffffffff81127e80 <list_lru_walk_node+0xd0>
ffffffff81127e7a:       0f 0b                   ud2
[...]
ffffffff81127ed0:       66 41 83 04 24 01       addw   $0x1,(%r12)
ffffffff81127ed6:       48 83 c4 38             add    $0x38,%rsp
ffffffff81127eda:       4c 89 e8                mov    %r13,%rax
ffffffff81127edd:       5b                      pop    %rbx
ffffffff81127ede:       41 5c                   pop    %r12
ffffffff81127ee0:       41 5d                   pop    %r13
ffffffff81127ee2:       41 5e                   pop    %r14
ffffffff81127ee4:       41 5f                   pop    %r15
ffffffff81127ee6:       c9                      leaveq 
ffffffff81127ee7:       c3                      retq

We are tripping over in list_for_each_safe and r14(000000572ead7838) is
obviously a garbage. So the lru is clobbered?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
