Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id C69956B0092
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 13:43:28 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q59so3221776wes.35
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 10:43:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id qq3si18758060wjc.3.2014.06.06.10.43.26
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 10:43:27 -0700 (PDT)
Date: Fri, 6 Jun 2014 13:43:17 -0400
From: Dave Jones <davej@redhat.com>
Subject: 3.15-rc8 oops in copy_page_rep after page fault.
Message-ID: <20140606174317.GA1741@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

Not much to go on here. It rebooted right after dumping this.

Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: fuse sctp tun hidp rfcomm llc2 af_key nfnetlink ipt_ULOG scsi_transport_iscsi bnep can_raw nfc caif_socket caif af_802154 ieee802154 phonet af_rxrpc can_bcm can pppoe pppox p
pp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm xfs libcrc32c crct10dif_pclmul crc32c_intel snd_hda_c
odec_hdmi snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec btusb snd_hwdep bluetooth e1000e snd_seq 6lowpan_iphc ghash_clmulni_intel snd_seq_device snd_pcm snd_timer 
shpchp microcode snd rfkill usb_debug ptp serio_raw pcspkr pps_core soundcore
CPU: 3 PID: 7553 Comm: trinity-c196 Not tainted 3.15.0-rc8+ #229
task: ffff880095966390 ti: ffff880002084000 task.ti: ffff880002084000
RIP: 0010:[<ffffffff8b3287b5>]  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10
RSP: 0000:ffff880002087d08  EFLAGS: 00010286
RAX: ffff880000000000 RBX: ffffea000053bf80 RCX: 0000000000000200
RDX: 0000000000000000 RSI: ffff880052766000 RDI: ffff880014efe000
RBP: ffff880002087d80 R08: 000000024e558000 R09: ffff880000000000
R10: 0000000000002c2a R11: 0000000000016ae0 R12: 000000000149d980
R13: ffff8800020a9000 R14: 00000000014a0000 R15: ffff880070d63f08
FS:  00007f3700519780(0000) GS:ffff88024d180000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff880052766000 CR3: 0000000002068000 CR4: 00000000001407e0
DR0: 0000627000019000 DR1: 0000000000a94000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000b0602
Stack:
 ffffffff8b1be8db ffff88011cec5000 80000000526008c5 ffff880070d633d8
 ffff880070d633d8 ffff8800020a9000 ffff880002090000 ffffea0001498000
 00000c1080000000 0000160000000000 ffff8800020a9000 00000c10800033e4
Call Trace:
 [<ffffffff8b1be8db>] ? do_huge_pmd_wp_page+0x5cb/0x850
 [<ffffffff8b187010>] handle_mm_fault+0x1e0/0xc50
 [<ffffffff8b1b4662>] ? kmem_cache_free+0x1c2/0x200
 [<ffffffff8b7472d9>] __do_page_fault+0x1c9/0x630
 [<ffffffff8b010a98>] ? perf_trace_sys_enter+0x38/0x180
 [<ffffffff8b11897b>] ? __acct_update_integrals+0x8b/0x120
 [<ffffffff8b747bfb>] ? preempt_count_sub+0xab/0x100
 [<ffffffff8b74775e>] do_page_fault+0x1e/0x70
 [<ffffffff8b7441b2>] page_fault+0x22/0x30
Code: 90 90 90 90 90 90 9c fa 65 48 3b 06 75 14 65 48 3b 56 08 75 0d 65 48 89 1e 65 48 89 4e 08 9d b0 01 c3 9d 30 c0 c3 b9 00 02 00 00 <f3> 48 a5 c3 0f 1f 80 00 00 00 00 eb ee 0f 1f 84 00 00 00
 00 00 
RIP  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10
 RSP <ffff880002087d08>
CR2: ffff880052766000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
