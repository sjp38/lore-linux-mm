Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 101B96B00AA
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:21:47 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id i8so893878qcq.21
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 13:21:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n6si71665282qel.147.2013.12.06.13.21.45
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 13:21:46 -0800 (PST)
Date: Fri, 6 Dec 2013 16:21:37 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: oops in pgtable_trans_huge_withdraw
Message-ID: <20131206212137.GA9561@redhat.com>
References: <20131206210254.GA7962@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131206210254.GA7962@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Fri, Dec 06, 2013 at 04:02:54PM -0500, Dave Jones wrote:
 
 > Call Trace:
 >  [<ffffffff811b13e2>] zap_huge_pmd+0x62/0x140
 >  [<ffffffff8117ac58>] unmap_single_vma+0x678/0x830
 >  [<ffffffff8117bea9>] unmap_vmas+0x49/0x90
 >  [<ffffffff81184da5>] exit_mmap+0xc5/0x170
 >  [<ffffffff8105104b>] mmput+0x6b/0x100
 >  [<ffffffff81055a18>] do_exit+0x298/0xce0
 >  [<ffffffff8105782c>] do_group_exit+0x4c/0xc0
 >  [<ffffffff8106a671>] get_signal_to_deliver+0x2d1/0x930
 >  [<ffffffff810024a8>] do_signal+0x48/0x610
 >  [<ffffffff810a9af9>] ? get_lock_stats+0x19/0x60
 >  [<ffffffff810aa27e>] ? put_lock_stats.isra.28+0xe/0x30
 >  [<ffffffff810aa7de>] ? lock_release_holdtime.part.29+0xee/0x170
 >  [<ffffffff8114f18e>] ? context_tracking_user_exit+0x4e/0x190
 >  [<ffffffff810ad1f5>] ? trace_hardirqs_on_caller+0x115/0x1e0
 >  [<ffffffff81002acc>] do_notify_resume+0x5c/0xa0
 >  [<ffffffff817587c6>] retint_signal+0x46/0x90

Same end result, but different trace..

Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: ipt_ULOG nfnetlink scsi_transport_iscsi af_802154 nfc irda crc_ccitt rds x25 atm appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 rfkill xfs libcrc32c snd_hda_codec_realtek snd_hda_codec_hdmi coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm crct10dif_pclmul crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc e1000e usb_debug snd_timer shpchp ptp snd pps_core soundcore
CPU: 3 PID: 24319 Comm: trinity-child3 Not tainted 3.13.0-rc2+ #23 
task: ffff88023e60d740 ti: ffff88021e64a000 task.ti: ffff88021e64a000
RIP: 0010:[<ffffffff8118e415>]  [<ffffffff8118e415>] pgtable_trans_huge_withdraw+0x55/0xc0
RSP: 0018:ffff88021e64bd28  EFLAGS: 00010206
RAX: 00000000026fffc0 RBX: 0000000000000000 RCX: 0000000000000027
RDX: 0000000000000000 RSI: ffff88009bfff000 RDI: ffff88009bfff000
RBP: ffff88021e64bd48 R08: ffff88023e60deb8 R09: ffff880224d73c00
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88009bfff000
R13: ffffea0000000000 R14: 0000000000000020 R15: ffff880221bf2200
FS:  00007f70aa5cc740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000020 CR3: 000000021ea97000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack:
 ffff88021e4e3b18 ffffea0008738000 0000000080000000 ffffea0000000000
 ffff88021e64bdc0 ffffffff811b1cec ffff88021ddc9550 0000000008738000
 ffff880200000000 ffff88009bfff000 0000000100000246 0000000000000000
Call Trace:
 [<ffffffff811b1cec>] split_huge_page_to_list+0x4ac/0x740
 [<ffffffff811b32ac>] __split_huge_page_pmd+0x11c/0x290
 [<ffffffff8118648d>] move_page_tables+0x21d/0x620
 [<ffffffff8118697b>] move_vma+0xeb/0x270
 [<ffffffff81186e76>] SyS_mremap+0x376/0x520
 [<ffffffff81760b64>] tracesys+0xdd/0xe2
Code: c1 e0 06 4a 8b 44 28 30 0f b7 00 38 c4 74 79 4c 89 e7 e8 af 03 eb ff 4c 89 e7 48 c1 e8 0c 48 c1 e0 06 49 8b 5c 05 20 4c 8d 73 20 <4c> 3b 73 20 74 35 e8 90 03 eb ff 4c 89 f7 48 89 c2 48 8b 43 20 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
