Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id DDC926B0036
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 16:21:09 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id i8so9336485qcq.37
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 13:21:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h5si7212373qas.119.2014.04.14.13.21.08
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 13:21:08 -0700 (PDT)
Date: Mon, 14 Apr 2014 16:20:59 -0400
From: Dave Jones <davej@redhat.com>
Subject: [3.14+] kernel BUG at mm/filemap.c:1347!
Message-ID: <20140414202059.GA11170@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com

git tree from yesterday afternoon sometime, before Linus cut .15-rc1

kernel BUG at mm/filemap.c:1347!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: 8021q garp bridge stp dlci snd_seq_dummy tun fuse rfcomm ipt_ULOG nfnetlink llc2 af_key scsi_transport_iscsi hidp can_raw bnep can_bcm nfc caif_socket caif af_802154 ieee802154 phonet af_rxrpc can pppoe pppox ppp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_codec_generic snd_hda_intel snd_hda_controller btusb snd_hda_codec snd_hwdep bluetooth snd_seq snd_seq_device snd_pcm xfs e1000e snd_timer crct10dif_pclmul snd crc32c_intel libcrc32c ghash_clmulni_intel ptp 6lowpan_iphc rfkill usb_debug shpchp soundcore pps_core microcode pcspkr serio_raw
CPU: 1 PID: 5440 Comm: trinity-c16 Not tainted 3.14.0+ #187
task: ffff8801efe79ae0 ti: ffff8802082e4000 task.ti: ffff8802082e4000
RIP: 0010:[<ffffffffb815aeab>]  [<ffffffffb815aeab>] find_get_pages_tag+0x1cb/0x220
RSP: 0000:ffff8802082e5c70  EFLAGS: 00010246
RAX: 7fffffffffffffff RBX: 000000000000000e RCX: 000000000000001d
RDX: 000000000000001d RSI: ffff880041c7d4f0 RDI: 0000000000000000
RBP: ffff8802082e5cd0 R08: 0000000000002600 R09: ffffea00075104dc
R10: 0000000000000100 R11: 0000000000000228 R12: ffff8802082e5d08
R13: 000000000000000a R14: 0000000000000101 R15: ffff8802082e5d20
FS:  00007f97c44f2740(0000) GS:ffff880244200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000166d000 CR3: 000000016515d000 CR4: 00000000001407e0
DR0: 00000000015e9000 DR1: 0000000000842000 DR2: 0000000001da3000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffffb815ad16 0000000000000000 ffff880067079da8 0000000000002681
 00000000000026c0 7fffffffffffffff 000000004110b5bc ffff8802082e5d10
 ffffea0007477a80 0000000000000000 ffff8802082e5d90 0000000000002fd6
Call Trace:
 [<ffffffffb815ad16>] ? find_get_pages_tag+0x36/0x220
 [<ffffffffb8168511>] pagevec_lookup_tag+0x21/0x30
 [<ffffffffb81595de>] filemap_fdatawait_range+0xbe/0x1e0
 [<ffffffffb8159727>] filemap_fdatawait+0x27/0x30
 [<ffffffffb81f2fa4>] sync_inodes_sb+0x204/0x2a0
 [<ffffffffb874d98f>] ? wait_for_completion+0xff/0x130
 [<ffffffffb81fa5b0>] ? vfs_fsync+0x40/0x40
 [<ffffffffb81fa5c9>] sync_inodes_one_sb+0x19/0x20
 [<ffffffffb81caab2>] iterate_supers+0xb2/0x110
 [<ffffffffb81fa864>] sys_sync+0x44/0xb0
 [<ffffffffb875c4a9>] ia32_do_call+0x13/0x13
Code: 89 c1 85 c9 0f 84 ee fe ff ff 8d 51 01 89 c8 f0 41 0f b1 11 39 c1 0f 84 20 ff ff ff eb e2 66 90 0f 0b 83 e7 01 0f 85 af fe ff ff <0f> 0b 0f 1f 00 e8 ab 23 f1 ff 48 89 75 a8 e8 82 dd 00 00 48 8b 
RIP  [<ffffffffb815aeab>] find_get_pages_tag+0x1cb/0x220
 RSP <ffff8802082e5c70>
---[ end trace ea01792c1c61cb22 ]---



1343                         /*
1344                          * This function is never used on a shmem/tmpfs
1345                          * mapping, so a swap entry won't be found here.
1346                          */
1347                         BUG();




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
