Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 99F216B003B
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 13:36:10 -0400 (EDT)
Date: Fri, 5 Jul 2013 13:36:01 -0400
From: Dave Jones <davej@redhat.com>
Subject: Bad page map / swap_free warnings.
Message-ID: <20130705173601.GA6898@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

[ 6821.834891] cc (14101) used greatest stack depth: 2256 bytes left
[ 6838.015259] swap_free: Unused swap offset entry 000ead4c
[ 6838.015947] BUG: Bad page map in process trinity  pte:1d5a9800 pmd:21e922067
[ 6838.017491] addr:000000000253a000 vm_flags:00100073 anon_vma:ffff88022fb7c9b0 mapping:          (null) index:253a
[ 6838.018765] Modules linked in: snd_seq_dummy bnep scsi_transport_iscsi nfnetlink ipt_ULOG rfcomm can_raw af_802154 phonet af_rxrpc af_key llc2 caif_socket caif bluetooth pppoe pppox ppp_generic slhc netrom rose can_bcm can ipx p8023 p8022 irda crc_ccitt x25 nfc rfkill rds ax25 appletalk psnap llc atm snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_intel pcspkr snd_hda_codec snd_hwdep snd_seq snd_seq_device usb_debug snd_pcm e1000e ptp pps_core snd_page_alloc snd_timer snd soundcore xfs libcrc32c
[ 6838.027772] CPU: 0 PID: 4486 Comm: trinity Not tainted 3.10.0+ #41 
[ 6838.030590]  0000000000000000 ffff880225781c90 ffffffff816efaee 000000000253a000
[ 6838.031532]  ffff880225781cd8 ffffffff811744ac 000000001d5a9800 000000000000253a
[ 6838.032620]  0000000002600000 ffff88021e9229d0 000000001d5a9800 ffff880225781e00
[ 6838.033793] Call Trace:
[ 6838.034156]  [<ffffffff816efaee>] dump_stack+0x4e/0x82
[ 6838.034861]  [<ffffffff811744ac>] print_bad_pte+0x18c/0x230
[ 6838.035607]  [<ffffffff81175d25>] unmap_single_vma+0x535/0x890
[ 6838.036373]  [<ffffffff81177029>] unmap_vmas+0x49/0x90
[ 6838.037046]  [<ffffffff8117f8c1>] exit_mmap+0xc1/0x170
[ 6838.037736]  [<ffffffff81049bbf>] mmput+0x6f/0x100
[ 6838.038377]  [<ffffffff81051c28>] do_exit+0x288/0xcd0
[ 6838.039067]  [<ffffffff810ba7b5>] ? trace_hardirqs_on_caller+0x115/0x1e0
[ 6838.039936]  [<ffffffff810ba88d>] ? trace_hardirqs_on+0xd/0x10
[ 6838.040692]  [<ffffffff810539ec>] do_group_exit+0x4c/0xc0
[ 6838.041397]  [<ffffffff81053a74>] SyS_exit_group+0x14/0x20
[ 6838.042257]  [<ffffffff81702a94>] tracesys+0xdd/0xe2
[ 6838.042861] Disabling lock debugging due to kernel taint
[ 6838.043508] swap_free: Unused swap offset entry 000ead4e
[ 6838.045204] BUG: Bad page map in process trinity  pte:1d5a9c00 pmd:21e922067
[ 6838.048785] addr:000000000253b000 vm_flags:00100073 anon_vma:ffff88022fb7c9b0 mapping:          (null) index:253b
[ 6838.051054] Modules linked in: snd_seq_dummy bnep scsi_transport_iscsi nfnetlink ipt_ULOG rfcomm can_raw af_802154 phonet af_rxrpc af_key llc2 caif_socket caif bluetooth pppoe pppox ppp_generic slhc netrom rose can_bcm can ipx p8023 p8022 irda crc_ccitt x25 nfc rfkill rds ax25 appletalk psnap llc atm snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_intel pcspkr snd_hda_codec snd_hwdep snd_seq snd_seq_device usb_debug snd_pcm e1000e ptp pps_core snd_page_alloc snd_timer snd soundcore xfs libcrc32c
[ 6838.063312] CPU: 0 PID: 4486 Comm: trinity Tainted: G    B        3.10.0+ #41 
[ 6838.068279]  0000000000000000 ffff880225781c90 ffffffff816efaee 000000000253b000
[ 6838.070323]  ffff880225781cd8 ffffffff811744ac 000000001d5a9c00 000000000000253b
[ 6838.072778]  0000000002600000 ffff88021e9229d8 000000001d5a9c00 ffff880225781e00
[ 6838.075106] Call Trace:
[ 6838.076537]  [<ffffffff816efaee>] dump_stack+0x4e/0x82
[ 6838.078269]  [<ffffffff811744ac>] print_bad_pte+0x18c/0x230
[ 6838.080044]  [<ffffffff81175d25>] unmap_single_vma+0x535/0x890
[ 6838.081866]  [<ffffffff81177029>] unmap_vmas+0x49/0x90
[ 6838.083762]  [<ffffffff8117f8c1>] exit_mmap+0xc1/0x170
[ 6838.085585]  [<ffffffff81049bbf>] mmput+0x6f/0x100
[ 6838.087284]  [<ffffffff81051c28>] do_exit+0x288/0xcd0
[ 6838.089013]  [<ffffffff810ba7b5>] ? trace_hardirqs_on_caller+0x115/0x1e0
[ 6838.090964]  [<ffffffff810ba88d>] ? trace_hardirqs_on+0xd/0x10
[ 6838.093282]  [<ffffffff810539ec>] do_group_exit+0x4c/0xc0
[ 6838.095108]  [<ffffffff81053a74>] SyS_exit_group+0x14/0x20
[ 6838.096867]  [<ffffffff81702a94>] tracesys+0xdd/0xe2
[ 6838.098540] swap_free: Unused swap offset entry 000ead54
[ 6838.100232] BUG: Bad page map in process trinity  pte:1d5aa800 pmd:21e922067
[ 6838.103977] addr:000000000253e000 vm_flags:00100073 anon_vma:ffff88022fb7c9b0 mapping:          (null) index:253e
[ 6838.106307] Modules linked in: snd_seq_dummy bnep scsi_transport_iscsi nfnetlink ipt_ULOG rfcomm can_raw af_802154 phonet af_rxrpc af_key llc2 caif_socket caif bluetooth pppoe pppox ppp_generic slhc netrom rose can_bcm can ipx p8023 p8022 irda crc_ccitt x25 nfc rfkill rds ax25 appletalk psnap llc atm snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_intel pcspkr snd_hda_codec snd_hwdep snd_seq snd_seq_device usb_debug snd_pcm e1000e ptp pps_core snd_page_alloc snd_timer snd soundcore xfs libcrc32c
[ 6838.118518] CPU: 0 PID: 4486 Comm: trinity Tainted: G    B        3.10.0+ #41 
[ 6838.124135]  0000000000000000 ffff880225781c90 ffffffff816efaee 000000000253e000
[ 6838.126380]  ffff880225781cd8 ffffffff811744ac 000000001d5aa800 000000000000253e
[ 6838.128736]  0000000002600000 ffff88021e9229f0 000000001d5aa800 ffff880225781e00
[ 6838.131153] Call Trace:
[ 6838.132792]  [<ffffffff816efaee>] dump_stack+0x4e/0x82
[ 6838.134608]  [<ffffffff811744ac>] print_bad_pte+0x18c/0x230
[ 6838.136391]  [<ffffffff81175d25>] unmap_single_vma+0x535/0x890
[ 6838.138183]  [<ffffffff81177029>] unmap_vmas+0x49/0x90
[ 6838.139877]  [<ffffffff8117f8c1>] exit_mmap+0xc1/0x170
[ 6838.141546]  [<ffffffff81049bbf>] mmput+0x6f/0x100
[ 6838.143322]  [<ffffffff81051c28>] do_exit+0x288/0xcd0
[ 6838.145028]  [<ffffffff810ba7b5>] ? trace_hardirqs_on_caller+0x115/0x1e0
[ 6838.146841]  [<ffffffff810ba88d>] ? trace_hardirqs_on+0xd/0x10
[ 6838.148546]  [<ffffffff810539ec>] do_group_exit+0x4c/0xc0
[ 6838.150195]  [<ffffffff81053a74>] SyS_exit_group+0x14/0x20
[ 6838.151854]  [<ffffffff81702a94>] tracesys+0xdd/0xe2
[ 6838.154337] swap_free: Unused swap offset entry 000ead47
[ 6838.156189] BUG: Bad page map in process trinity  pte:1d5a8e00 pmd:22fa8a067
[ 6838.159720] addr:00007fffaf3eb000 vm_flags:00100173 anon_vma:ffff88022fb7c7c0 mapping:          (null) index:7fffffff8
[ 6838.162285] Modules linked in: snd_seq_dummy bnep scsi_transport_iscsi nfnetlink ipt_ULOG rfcomm can_raw af_802154 phonet af_rxrpc af_key llc2 caif_socket caif bluetooth pppoe pppox ppp_generic slhc netrom rose can_bcm can ipx p8023 p8022 irda crc_ccitt x25 nfc rfkill rds ax25 appletalk psnap llc atm snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_intel pcspkr snd_hda_codec snd_hwdep snd_seq snd_seq_device usb_debug snd_pcm e1000e ptp pps_core snd_page_alloc snd_timer snd soundcore xfs libcrc32c
[ 6838.190667] CPU: 1 PID: 4486 Comm: trinity Tainted: G    B        3.10.0+ #41 
[ 6838.203589]  0000000000000000 ffff880225781c90 ffffffff816efaee 00007fffaf3eb000
[ 6838.209187]  ffff880225781cd8 ffffffff811744ac 000000001d5a8e00 00000007fffffff8
[ 6838.216944]  00007fffaf3f2000 ffff88022fa8af58 000000001d5a8e00 ffff880225781e00
[ 6838.224284] Call Trace:
[ 6838.229487]  [<ffffffff816efaee>] dump_stack+0x4e/0x82
[ 6838.235111]  [<ffffffff811744ac>] print_bad_pte+0x18c/0x230
[ 6838.240654]  [<ffffffff81175d25>] unmap_single_vma+0x535/0x890
[ 6838.245940]  [<ffffffff81177029>] unmap_vmas+0x49/0x90
[ 6838.251230]  [<ffffffff8117f8c1>] exit_mmap+0xc1/0x170
[ 6838.256808]  [<ffffffff81049bbf>] mmput+0x6f/0x100
[ 6838.261524]  [<ffffffff81051c28>] do_exit+0x288/0xcd0
[ 6838.266976]  [<ffffffff810ba7b5>] ? trace_hardirqs_on_caller+0x115/0x1e0
[ 6838.272154]  [<ffffffff810ba88d>] ? trace_hardirqs_on+0xd/0x10
[ 6838.277814]  [<ffffffff810539ec>] do_group_exit+0x4c/0xc0
[ 6838.282580]  [<ffffffff81053a74>] SyS_exit_group+0x14/0x20
[ 6838.287494]  [<ffffffff81702a94>] tracesys+0xdd/0xe2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
