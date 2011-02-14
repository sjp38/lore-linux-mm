Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B25D18D0039
	for <linux-mm@kvack.org>; Sun, 13 Feb 2011 19:09:00 -0500 (EST)
Received: by fxm12 with SMTP id 12so4991043fxm.14
        for <linux-mm@kvack.org>; Sun, 13 Feb 2011 16:08:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
References: <20110207032407.GA27404@ca-server1.us.oracle.com>
	<1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
Date: Mon, 14 Feb 2011 00:08:56 +0000
Message-ID: <AANLkTimFATx-gYVgY_pVdZsySSBmXvKFkhTJUeVFBcop@mail.gmail.com>
Subject: Re: [PATCH V2 0/3] drivers/staging: zcache: dynamic page cache/swap compression
From: Matt <jackdachef@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@zeniv.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

On Wed, Feb 9, 2011 at 1:03 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
[snip]
>
> If I've missed anything important, please let me know!
>
> Thanks again!
> Dan
>

Hi Dan,

thank you so much for answering my email in such detail !

I shall pick up on that mail in my next email sending to the mailing list :)


currently I've got a problem with btrfs which seems to get triggered
by cleancache get-operations:


Feb 14 00:37:19 lupus kernel: [ 2831.297377] device fsid
354120c992a00761-5fa07d400126a895 devid 1 transid 7
/dev/mapper/portage
Feb 14 00:37:19 lupus kernel: [ 2831.297698] btrfs: enabling disk space caching
Feb 14 00:37:19 lupus kernel: [ 2831.297700] btrfs: force lzo compression
Feb 14 00:37:19 lupus kernel: [ 2831.315844] zcache: created ephemeral
tmem pool, id=3
Feb 14 00:39:20 lupus kernel: [ 2951.853188] BUG: unable to handle
kernel paging request at 0000000001400050
Feb 14 00:39:20 lupus kernel: [ 2951.853219] IP: [<ffffffff8133ef1b>]
btrfs_encode_fh+0x2b/0x120
Feb 14 00:39:20 lupus kernel: [ 2951.853242] PGD 0
Feb 14 00:39:20 lupus kernel: [ 2951.853251] Oops: 0000 [#1] PREEMPT SMP
Feb 14 00:39:20 lupus kernel: [ 2951.853275] last sysfs file:
/sys/devices/platform/coretemp.3/temp1_input
Feb 14 00:39:20 lupus kernel: [ 2951.853295] CPU 4
Feb 14 00:39:20 lupus kernel: [ 2951.853303] Modules linked in: radeon
ttm drm_kms_helper cfbcopyarea cfbimgblt cfbfillrect ipt_REJECT
ipt_LOG xt_limit xt_tcpudp xt_state nf_nat_irc nf_conntrack_irc
nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp
iptable_filter ipt_addrtype xt_DSCP xt_dscp xt_iprange ip_tables
ip6table_filter xt_NFQUEUE xt_owner xt_hashlimit xt_conntrack xt_mark
xt_multiport xt_connmark nf_conntrack xt_string ip6_tables x_tables
it87 hwmon_vid coretemp snd_seq_dummy snd_seq_oss snd_seq_midi_event
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi
snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm
snd_timer snd soundcore i2c_i801 wmi e1000e shpchp snd_page_alloc
libphy e1000 scsi_wait_scan sl811_hcd ohci_hcd ssb usb_storage
ehci_hcd [last unloaded: tg3]
Feb 14 00:39:20 lupus kernel: [ 2951.853682]
Feb 14 00:39:20 lupus kernel: [ 2951.853690] Pid: 11394, comm:
btrfs-transacti Not tainted 2.6.37-plus_v16_zcache #4 FMP55/ipower
G3710
Feb 14 00:39:20 lupus kernel: [ 2951.853725] RIP:
0010:[<ffffffff8133ef1b>]  [<ffffffff8133ef1b>]
btrfs_encode_fh+0x2b/0x120
Feb 14 00:39:20 lupus kernel: [ 2951.853751] RSP:
0018:ffff880129a11b00  EFLAGS: 00010246
Feb 14 00:39:20 lupus kernel: [ 2951.853767] RAX: 00000000000000ff
RBX: ffff88014a1ce628 RCX: 0000000000000000
Feb 14 00:39:20 lupus kernel: [ 2951.853788] RDX: ffff880129a11b3c
RSI: ffff880129a11b70 RDI: 0000000000000006
Feb 14 00:39:20 lupus kernel: [ 2951.853808] RBP: 0000000001400000
R08: ffffffff8133eef0 R09: ffff880129a11c68
Feb 14 00:39:20 lupus kernel: [ 2951.853829] R10: 0000000000000001
R11: 0000000000000001 R12: ffff88014a1ce780
Feb 14 00:39:20 lupus kernel: [ 2951.853849] R13: ffff88021fefc000
R14: ffff88021fef9000 R15: 0000000000000000
Feb 14 00:39:20 lupus kernel: [ 2951.853870] FS:
0000000000000000(0000) GS:ffff8800bf500000(0000)
knlGS:0000000000000000
Feb 14 00:39:20 lupus kernel: [ 2951.853894] CS:  0010 DS: 0000 ES:
0000 CR0: 000000008005003b
Feb 14 00:39:20 lupus kernel: [ 2951.853911] CR2: 0000000001400050
CR3: 0000000001c27000 CR4: 00000000000006e0
Feb 14 00:39:20 lupus kernel: [ 2951.853932] DR0: 0000000000000000
DR1: 0000000000000000 DR2: 0000000000000000
Feb 14 00:39:20 lupus kernel: [ 2951.853952] DR3: 0000000000000000
DR6: 00000000ffff0ff0 DR7: 0000000000000400
Feb 14 00:39:20 lupus kernel: [ 2951.853973] Process btrfs-transacti
(pid: 11394, threadinfo ffff880129a10000, task ffff880202e4ac40)
Feb 14 00:39:20 lupus kernel: [ 2951.853999] Stack:
Feb 14 00:39:20 lupus kernel: [ 2951.854006]  ffff880129a11b50
ffff880000000003 ffff88003c60a098 0000000000000003
Feb 14 00:39:20 lupus kernel: [ 2951.854035]  ffffffffffffffff
ffffffff810e6aaa 0000000000000000 0000000602e4ac40
Feb 14 00:39:20 lupus kernel: [ 2951.854063]  ffffffff8133e3f0
ffffffff810e6cee 0000000000001000 0000000000000000
Feb 14 00:39:20 lupus kernel: [ 2951.854092] Call Trace:
Feb 14 00:39:20 lupus kernel: [ 2951.854103]  [<ffffffff810e6aaa>] ?
cleancache_get_key+0x4a/0x60
Feb 14 00:39:20 lupus kernel: [ 2951.854122]  [<ffffffff8133e3f0>] ?
btrfs_wake_function+0x0/0x20
Feb 14 00:39:20 lupus kernel: [ 2951.854140]  [<ffffffff810e6cee>] ?
__cleancache_flush_inode+0x3e/0x70
Feb 14 00:39:20 lupus kernel: [ 2951.854161]  [<ffffffff810b34d2>] ?
truncate_inode_pages_range+0x42/0x440
Feb 14 00:39:20 lupus kernel: [ 2951.854182]  [<ffffffff812f115e>] ?
btrfs_search_slot+0x89e/0xa00
Feb 14 00:39:20 lupus kernel: [ 2951.854201]  [<ffffffff810c3a45>] ?
unmap_mapping_range+0xc5/0x2a0
Feb 14 00:39:20 lupus kernel: [ 2951.854220]  [<ffffffff810b3930>] ?
truncate_pagecache+0x40/0x70
Feb 14 00:39:20 lupus kernel: [ 2951.854240]  [<ffffffff813458b1>] ?
btrfs_truncate_free_space_cache+0x81/0xe0
Feb 14 00:39:20 lupus kernel: [ 2951.854261]  [<ffffffff812fce15>] ?
btrfs_write_dirty_block_groups+0x245/0x500
Feb 14 00:39:20 lupus kernel: [ 2951.854283]  [<ffffffff812fcb6a>] ?
btrfs_run_delayed_refs+0x1ba/0x220
Feb 14 00:39:20 lupus kernel: [ 2951.854304]  [<ffffffff8130afff>] ?
commit_cowonly_roots+0xff/0x1d0
Feb 14 00:39:20 lupus kernel: [ 2951.854323]  [<ffffffff8130c583>] ?
btrfs_commit_transaction+0x363/0x760
Feb 14 00:39:20 lupus kernel: [ 2951.854344]  [<ffffffff81067ea0>] ?
autoremove_wake_function+0x0/0x30
Feb 14 00:39:20 lupus kernel: [ 2951.854364]  [<ffffffff81305bc3>] ?
transaction_kthread+0x283/0x2a0
Feb 14 00:39:20 lupus kernel: [ 2951.854383]  [<ffffffff81305940>] ?
transaction_kthread+0x0/0x2a0
Feb 14 00:39:20 lupus kernel: [ 2951.854401]  [<ffffffff81305940>] ?
transaction_kthread+0x0/0x2a0
Feb 14 00:39:20 lupus kernel: [ 2951.854420]  [<ffffffff81067a16>] ?
kthread+0x96/0xa0
Feb 14 00:39:20 lupus kernel: [ 2951.854437]  [<ffffffff81003514>] ?
kernel_thread_helper+0x4/0x10
Feb 14 00:39:20 lupus kernel: [ 2951.854455]  [<ffffffff81067980>] ?
kthread+0x0/0xa0
Feb 14 00:39:20 lupus kernel: [ 2951.854471]  [<ffffffff81003510>] ?
kernel_thread_helper+0x0/0x10
Feb 14 00:39:20 lupus kernel: [ 2951.854488] Code: 55 b8 ff 00 00 00
53 48 89 fb 48 83 ec 18 48 8b 6f 10 8b 3a 83 ff 04 0f 86 d5 00 00 00
85 c9 0f 95 c1 83 ff 07 0f 86 d5 00 00 00 <48> 8b 45 50 bf 05 00 00 00
48 89 06 84 c9 48 8b 85 68 fe ff ff
Feb 14 00:39:20 lupus kernel: [ 2951.854742] RIP  [<ffffffff8133ef1b>]
btrfs_encode_fh+0x2b/0x120
Feb 14 00:39:20 lupus kernel: [ 2951.854762]  RSP <ffff880129a11b00>
Feb 14 00:39:20 lupus kernel: [ 2951.854773] CR2: 0000000001400050
Feb 14 00:39:20 lupus kernel: [ 2951.860906] ---[ end trace
f831c5ceeaa49287 ]---

in my case I had compress-force with lzo and disk_cache enabled


another user of the kernel I'm currently running has had the same
problem with zcache
(http://forums.gentoo.org/viewtopic-p-6571799.html#6571799)

(looks like in his case compression and any other fancy additional
features weren't enabled)


changes made by this kernel or patchset to btrfs are from
* io-less dirty throttling patchset (44 patches)
* zcache V2 ("[PATCH] staging: zcache: fix memory leak" should be
applied in both cases)
* PATCH] fix (latent?) memory corruption in btrfs_encode_fh()
* btrfs-unstable changes to state of
3a90983dbdcb2f4f48c0d771d8e5b4d88f27fae6 (so practically equals btrfs
from 2.6.38-rc4+)

I haven't tried downgrading to vanilla 2.6.37 with zcache only, yet,

but kind of upgraded btrfs to the latest state of the btrfs-unstable
repository (http://git.eu.kernel.org/?p=linux/kernel/git/mason/btrfs-unstable.git;a=summary)
namely 3a90983dbdcb2f4f48c0d771d8e5b4d88f27fae6

this also didn't help and seemed to produce the same error-message

so to summarize:

1) error message appearing with all 4 patchsets applied changing
btrfs-code and compress-force=lzo and disk_cache enabled

2) error message appearing with default mount-options and btrfs from
2.6.37 and changes for zcache & io-less dirty throttling patchset
applied (first 2 patch(sets)) from list)


in my case I tried to extract / play back a 1.7 GiB tarball of my
portage-directory (lots of small files and some tar.bzip2 archives)
via pbzip2 or 7z when the error happened and the message was shown

Due to KMS sound (webradio streaming) was still running but I couldn't
continue work (X switching to kernel output) so I did the magic sysrq
combo (reisub)


Does that BUG message ring a bell for anyone ?

(if I should leave out anyone from the CC in the next emails or
future, please holler - I don't want to spam your inboxes)

Thanks

Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
