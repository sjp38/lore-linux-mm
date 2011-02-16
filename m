Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7B18D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 19:12:30 -0500 (EST)
Received: by fxm12 with SMTP id 12so815294fxm.14
        for <linux-mm@kvack.org>; Tue, 15 Feb 2011 16:12:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTim6n9QqEYr32RPS1Ne0aKpDEf1ZNiNGz2ZvS-EO@mail.gmail.com>
References: <20110207032407.GA27404@ca-server1.us.oracle.com>
	<1ddd01a8-591a-42bc-8bb3-561843b31acb@default>
	<AANLkTimFATx-gYVgY_pVdZsySSBmXvKFkhTJUeVFBcop@mail.gmail.com>
	<AANLkTimqSSxHrLhL9t4DOmDeuAA41B9e-qnr+vnUsucL@mail.gmail.com>
	<AANLkTi=4QkV4wtMmDd6+XXhvkva+fq9m5PVYGC0qBUc3@mail.gmail.com>
	<AANLkTim6n9QqEYr32RPS1Ne0aKpDEf1ZNiNGz2ZvS-EO@mail.gmail.com>
Date: Wed, 16 Feb 2011 00:12:21 +0000
Message-ID: <AANLkTimOssgM7JYSpwB=5zmF_JJ2ByH+PWO7N+YZNB_y@mail.gmail.com>
Subject: Re: [PATCH V2 0/3] drivers/staging: zcache: dynamic page cache/swap compression
From: Matt <jackdachef@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, linux-btrfs@vger.kernel.org, Josef Bacik <josef@redhat.com>, Dan Rosenberg <drosenberg@vsecurity.com>, Yan Zheng <zheng.z.yan@intel.com>, miaox@cn.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>

On Mon, Feb 14, 2011 at 4:35 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Mon, Feb 14, 2011 at 10:29 AM, Matt <jackdachef@gmail.com> wrote:
>> On Mon, Feb 14, 2011 at 1:24 AM, Matt <jackdachef@gmail.com> wrote:
>>> On Mon, Feb 14, 2011 at 12:08 AM, Matt <jackdachef@gmail.com> wrote:
>>>> On Wed, Feb 9, 2011 at 1:03 AM, Dan Magenheimer
>>>> <dan.magenheimer@oracle.com> wrote:
>>>> [snip]
>>>>>
>>>>> If I've missed anything important, please let me know!
>>>>>
>>>>> Thanks again!
>>>>> Dan
>>>>>
>>>>
>>>> Hi Dan,
>>>>
>>>> thank you so much for answering my email in such detail !
>>>>
>>>> I shall pick up on that mail in my next email sending to the mailing l=
ist :)
>>>>
>>>>
>>>> currently I've got a problem with btrfs which seems to get triggered
>>>> by cleancache get-operations:
>>>>
>>>>
>>>> Feb 14 00:37:19 lupus kernel: [ 2831.297377] device fsid
>>>> 354120c992a00761-5fa07d400126a895 devid 1 transid 7
>>>> /dev/mapper/portage
>>>> Feb 14 00:37:19 lupus kernel: [ 2831.297698] btrfs: enabling disk spac=
e caching
>>>> Feb 14 00:37:19 lupus kernel: [ 2831.297700] btrfs: force lzo compress=
ion
>>>> Feb 14 00:37:19 lupus kernel: [ 2831.315844] zcache: created ephemeral
>>>> tmem pool, id=3D3
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853188] BUG: unable to handle
>>>> kernel paging request at 0000000001400050
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853219] IP: [<ffffffff8133ef1b>]
>>>> btrfs_encode_fh+0x2b/0x120
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853242] PGD 0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853251] Oops: 0000 [#1] PREEMPT S=
MP
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853275] last sysfs file:
>>>> /sys/devices/platform/coretemp.3/temp1_input
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853295] CPU 4
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853303] Modules linked in: radeon
>>>> ttm drm_kms_helper cfbcopyarea cfbimgblt cfbfillrect ipt_REJECT
>>>> ipt_LOG xt_limit xt_tcpudp xt_state nf_nat_irc nf_conntrack_irc
>>>> nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp
>>>> iptable_filter ipt_addrtype xt_DSCP xt_dscp xt_iprange ip_tables
>>>> ip6table_filter xt_NFQUEUE xt_owner xt_hashlimit xt_conntrack xt_mark
>>>> xt_multiport xt_connmark nf_conntrack xt_string ip6_tables x_tables
>>>> it87 hwmon_vid coretemp snd_seq_dummy snd_seq_oss snd_seq_midi_event
>>>> snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi
>>>> snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm
>>>> snd_timer snd soundcore i2c_i801 wmi e1000e shpchp snd_page_alloc
>>>> libphy e1000 scsi_wait_scan sl811_hcd ohci_hcd ssb usb_storage
>>>> ehci_hcd [last unloaded: tg3]
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853682]
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853690] Pid: 11394, comm:
>>>> btrfs-transacti Not tainted 2.6.37-plus_v16_zcache #4 FMP55/ipower
>>>> G3710
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853725] RIP:
>>>> 0010:[<ffffffff8133ef1b>] =A0[<ffffffff8133ef1b>]
>>>> btrfs_encode_fh+0x2b/0x120
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853751] RSP:
>>>> 0018:ffff880129a11b00 =A0EFLAGS: 00010246
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853767] RAX: 00000000000000ff
>>>> RBX: ffff88014a1ce628 RCX: 0000000000000000
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853788] RDX: ffff880129a11b3c
>>>> RSI: ffff880129a11b70 RDI: 0000000000000006
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853808] RBP: 0000000001400000
>>>> R08: ffffffff8133eef0 R09: ffff880129a11c68
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853829] R10: 0000000000000001
>>>> R11: 0000000000000001 R12: ffff88014a1ce780
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853849] R13: ffff88021fefc000
>>>> R14: ffff88021fef9000 R15: 0000000000000000
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853870] FS:
>>>> 0000000000000000(0000) GS:ffff8800bf500000(0000)
>>>> knlGS:0000000000000000
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853894] CS: =A00010 DS: 0000 ES:
>>>> 0000 CR0: 000000008005003b
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853911] CR2: 0000000001400050
>>>> CR3: 0000000001c27000 CR4: 00000000000006e0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853932] DR0: 0000000000000000
>>>> DR1: 0000000000000000 DR2: 0000000000000000
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853952] DR3: 0000000000000000
>>>> DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853973] Process btrfs-transacti
>>>> (pid: 11394, threadinfo ffff880129a10000, task ffff880202e4ac40)
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.853999] Stack:
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854006] =A0ffff880129a11b50
>>>> ffff880000000003 ffff88003c60a098 0000000000000003
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854035] =A0ffffffffffffffff
>>>> ffffffff810e6aaa 0000000000000000 0000000602e4ac40
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854063] =A0ffffffff8133e3f0
>>>> ffffffff810e6cee 0000000000001000 0000000000000000
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854092] Call Trace:
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854103] =A0[<ffffffff810e6aaa>] ?
>>>> cleancache_get_key+0x4a/0x60
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854122] =A0[<ffffffff8133e3f0>] ?
>>>> btrfs_wake_function+0x0/0x20
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854140] =A0[<ffffffff810e6cee>] ?
>>>> __cleancache_flush_inode+0x3e/0x70
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854161] =A0[<ffffffff810b34d2>] ?
>>>> truncate_inode_pages_range+0x42/0x440
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854182] =A0[<ffffffff812f115e>] ?
>>>> btrfs_search_slot+0x89e/0xa00
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854201] =A0[<ffffffff810c3a45>] ?
>>>> unmap_mapping_range+0xc5/0x2a0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854220] =A0[<ffffffff810b3930>] ?
>>>> truncate_pagecache+0x40/0x70
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854240] =A0[<ffffffff813458b1>] ?
>>>> btrfs_truncate_free_space_cache+0x81/0xe0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854261] =A0[<ffffffff812fce15>] ?
>>>> btrfs_write_dirty_block_groups+0x245/0x500
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854283] =A0[<ffffffff812fcb6a>] ?
>>>> btrfs_run_delayed_refs+0x1ba/0x220
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854304] =A0[<ffffffff8130afff>] ?
>>>> commit_cowonly_roots+0xff/0x1d0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854323] =A0[<ffffffff8130c583>] ?
>>>> btrfs_commit_transaction+0x363/0x760
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854344] =A0[<ffffffff81067ea0>] ?
>>>> autoremove_wake_function+0x0/0x30
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854364] =A0[<ffffffff81305bc3>] ?
>>>> transaction_kthread+0x283/0x2a0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854383] =A0[<ffffffff81305940>] ?
>>>> transaction_kthread+0x0/0x2a0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854401] =A0[<ffffffff81305940>] ?
>>>> transaction_kthread+0x0/0x2a0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854420] =A0[<ffffffff81067a16>] ?
>>>> kthread+0x96/0xa0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854437] =A0[<ffffffff81003514>] ?
>>>> kernel_thread_helper+0x4/0x10
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854455] =A0[<ffffffff81067980>] ?
>>>> kthread+0x0/0xa0
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854471] =A0[<ffffffff81003510>] ?
>>>> kernel_thread_helper+0x0/0x10
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854488] Code: 55 b8 ff 00 00 00
>>>> 53 48 89 fb 48 83 ec 18 48 8b 6f 10 8b 3a 83 ff 04 0f 86 d5 00 00 00
>>>> 85 c9 0f 95 c1 83 ff 07 0f 86 d5 00 00 00 <48> 8b 45 50 bf 05 00 00 00
>>>> 48 89 06 84 c9 48 8b 85 68 fe ff ff
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854742] RIP =A0[<ffffffff8133ef1b=
>]
>>>> btrfs_encode_fh+0x2b/0x120
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854762] =A0RSP <ffff880129a11b00>
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.854773] CR2: 0000000001400050
>>>> Feb 14 00:39:20 lupus kernel: [ 2951.860906] ---[ end trace
>>>> f831c5ceeaa49287 ]---
>>>>
>>>> in my case I had compress-force with lzo and disk_cache enabled
>>>>
>>>>
>>>> another user of the kernel I'm currently running has had the same
>>>> problem with zcache
>>>> (http://forums.gentoo.org/viewtopic-p-6571799.html#6571799)
>>>>
>>>> (looks like in his case compression and any other fancy additional
>>>> features weren't enabled)
>>>>
>>>>
>>>> changes made by this kernel or patchset to btrfs are from
>>>> * io-less dirty throttling patchset (44 patches)
>>>> * zcache V2 ("[PATCH] staging: zcache: fix memory leak" should be
>>>> applied in both cases)
>>>> * PATCH] fix (latent?) memory corruption in btrfs_encode_fh()
>>>> * btrfs-unstable changes to state of
>>>> 3a90983dbdcb2f4f48c0d771d8e5b4d88f27fae6 (so practically equals btrfs
>>>> from 2.6.38-rc4+)
>>>>
>>>> I haven't tried downgrading to vanilla 2.6.37 with zcache only, yet,
>>>>
>>>> but kind of upgraded btrfs to the latest state of the btrfs-unstable
>>>> repository (http://git.eu.kernel.org/?p=3Dlinux/kernel/git/mason/btrfs=
-unstable.git;a=3Dsummary)
>>>> namely 3a90983dbdcb2f4f48c0d771d8e5b4d88f27fae6
>>>>
>>>> this also didn't help and seemed to produce the same error-message
>>>>
>>>> so to summarize:
>>>>
>>>> 1) error message appearing with all 4 patchsets applied changing
>>>> btrfs-code and compress-force=3Dlzo and disk_cache enabled
>>>>
>>>> 2) error message appearing with default mount-options and btrfs from
>>>> 2.6.37 and changes for zcache & io-less dirty throttling patchset
>>>> applied (first 2 patch(sets)) from list)
>>>>
>>>>
>>>> in my case I tried to extract / play back a 1.7 GiB tarball of my
>>>> portage-directory (lots of small files and some tar.bzip2 archives)
>>>> via pbzip2 or 7z when the error happened and the message was shown
>>>>
>>>> Due to KMS sound (webradio streaming) was still running but I couldn't
>>>> continue work (X switching to kernel output) so I did the magic sysrq
>>>> combo (reisub)
>>>>
>>>>
>>>> Does that BUG message ring a bell for anyone ?
>>>>
>>>> (if I should leave out anyone from the CC in the next emails or
>>>> future, please holler - I don't want to spam your inboxes)
>>>>
>>>> Thanks
>>>>
>>>> Matt
>>>>
>>>
>>>
>>> OK,
>>>
>>> here's the output of a kernel -
>>>
>>> staying as close to vanilla (2.6.37) as the current situation allows
>>> (only including some corruption or leak fixes for zram & zcache and
>>> "zram_xvmalloc: 64K page fixes and optimizations" (and 2 reiserfs
>>> fixes)):
>>>
>>> so in total the following patches are included in this new kernel
>>> (2.6.37-zcache):
>>>
>>> zram changes:
>>> 1 zram: Fix sparse warning 'Using plain integer as NULL pointer'
>>> 2 [PATCH] zram: fix data corruption issue
>>> 3 [PATCH 0/7][v2] zram_xvmalloc: 64K page fixes and optimizations
>>>
>>> zcache:
>>> 1 zcache-linux-2.6.37-110205
>>> 2 [PATCH] staging: zcache: fix memory leak
>>> 3 [PATCH] zcache: Fix build error when sysfs is not defined
>>>
>>> reiserfs:
>>> 1 [PATCH] reiserfs: Make sure va_end() is always called after
>>> 2 [patch] reiserfs: potential ERR_PTR dereference
>>>
>>>
>>> the same procedure:
>>>
>>> trying to extract the mentioned portage-tarball:
>>>
>>> time (7z e -so -tbzip2 -mmt=3D5 /system/portage_backup_022011.tbz2 | ta=
r
>>> -xp -C /usr/gentoo/)
>>>
>>>
>>> this hopefully should make it easier to track down the problem:
>>>
>>>
>>> Feb 14 01:59:59 lupus kernel: [ =A0364.777143] device fsid
>>> 684a4213565dd3fe-ca991821badc2aac devid 1 transid 7
>>> /dev/mapper/portage
>>> Feb 14 01:59:59 lupus kernel: [ =A0364.844994] zcache: created ephemera=
l
>>> tmem pool, id=3D2
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.577573] BUG: unable to handle
>>> kernel paging request at 0000000037610050
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.577605] IP: [<ffffffff81338cbb>]
>>> btrfs_encode_fh+0x2b/0x110
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.577630] PGD 0
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.577640] Oops: 0000 [#1] PREEMPT =
SMP
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.577665] last sysfs file:
>>> /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.577693] CPU 5
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.577701] Modules linked in: radeo=
n
>>> ttm drm_kms_helper cfbcopyarea cfbimgblt cfbfillrect ipt_REJECT
>>> ipt_LOG xt_limit xt_tcpudp xt_state nf_nat_irc nf_conntrack_irc
>>> nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp
>>> iptable_filter ipt_addrtype xt_DSCP xt_dscp xt_iprange ip_tables
>>> ip6table_filter xt_NFQUEUE xt_owner xt_hashlimit xt_conntrack xt_mark
>>> xt_multiport xt_connmark nf_conntrack xt_string ip6_tables x_tables
>>> it87 hwmon_vid coretemp snd_seq_dummy snd_seq_oss snd_seq_midi_event
>>> snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi
>>> snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm
>>> snd_timer snd e1000e soundcore i2c_i801 shpchp snd_page_alloc wmi
>>> libphy e1000 scsi_wait_scan sl811_hcd ohci_hcd ssb usb_storage
>>> ehci_hcd [last unloaded: tg3]
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578114]
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578124] Pid: 8285, comm: tar Not
>>> tainted 2.6.37-zcache #2 FMP55/ipower G3710
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578146] RIP:
>>> 0010:[<ffffffff81338cbb>] =A0[<ffffffff81338cbb>]
>>> btrfs_encode_fh+0x2b/0x110
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578172] RSP:
>>> 0018:ffff88023ea9dcc8 =A0EFLAGS: 00010246
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578189] RAX: 00000000000000ff
>>> RBX: ffff8800b8643228 RCX: 0000000000000000
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578210] RDX: ffff88023ea9dd04
>>> RSI: ffff88023ea9dd38 RDI: 0000000000000006
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578230] RBP: 0000000037610000
>>> R08: ffffffff81338c90 R09: 0000000000000000
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578251] R10: 0000000000000019
>>> R11: 0000000000000001 R12: ffff8800b8643380
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578272] R13: ffff8800b8643258
>>> R14: 00007fff806f1f00 R15: 0000000000000000
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578293] FS:
>>> 00007f823d7ed700(0000) GS:ffff8800bf540000(0000)
>>> knlGS:0000000000000000
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578317] CS: =A00010 DS: 0000 ES:
>>> 0000 CR0: 0000000080050033
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578334] CR2: 0000000037610050
>>> CR3: 000000023dcef000 CR4: 00000000000006e0
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578356] DR0: 0000000000000000
>>> DR1: 0000000000000000 DR2: 0000000000000000
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578377] DR3: 0000000000000000
>>> DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578398] Process tar (pid: 8285,
>>> threadinfo ffff88023ea9c000, task ffff88023e8b9d40)
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578421] Stack:
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578428] =A0000000013d096000
>>> ffff88023ed84800 ffff88023ea9c000 0000000000000002
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578458] =A0ffffffffffffffff
>>> ffffffff810e3b1a 0000000000000001 000000061e1d5240
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578486] =A0fffffffffffffffb
>>> ffffffff810e3d5e ffff88010f383000 0000001ab86cb908
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578514] Call Trace:
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578525] =A0[<ffffffff810e3b1a>] =
?
>>> cleancache_get_key+0x4a/0x60
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578544] =A0[<ffffffff810e3d5e>] =
?
>>> __cleancache_flush_inode+0x3e/0x70
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578565] =A0[<ffffffff810b0ed2>] =
?
>>> truncate_inode_pages_range+0x42/0x440
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578586] =A0[<ffffffff81338451>] =
?
>>> btrfs_tree_unlock+0x41/0x50
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578605] =A0[<ffffffff812e4ed5>] =
?
>>> btrfs_release_path+0x15/0x70
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578624] =A0[<ffffffff8130bf29>] =
?
>>> btrfs_run_delayed_iputs+0x49/0x120
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578644] =A0[<ffffffff813107e7>] =
?
>>> btrfs_evict_inode+0x27/0x1e0
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578663] =A0[<ffffffff810fc3aa>] =
?
>>> evict+0x1a/0xa0
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578678] =A0[<ffffffff810fc6bd>] =
?
>>> iput+0x1cd/0x2b0
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578694] =A0[<ffffffff810f266f>] =
?
>>> do_unlinkat+0x12f/0x1d0
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578712] =A0[<ffffffff810027bb>] =
?
>>> system_call_fastpath+0x16/0x1b
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578730] Code: 55 b8 ff 00 00 00
>>> 53 48 89 fb 48 83 ec 18 48 8b 6f 10 8b 3a 83 ff 04 0f 86 d5 00 00 00
>>> 85 c9 0f 95 c1 83 ff 07 0f 86 d5 00 00 00 <48> 8b 45 50 bf 05 00 00 00
>>> 48 89 06 84 c9 48 8b 85 68 fe ff ff
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.578986] RIP =A0[<ffffffff81338cb=
b>]
>>> btrfs_encode_fh+0x2b/0x110
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.579081] =A0RSP <ffff88023ea9dcc8=
>
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.579093] CR2: 0000000037610050
>>> Feb 14 02:02:49 lupus kernel: [ =A0534.587513] ---[ end trace
>>> c596b12e66c0b360 ]---
>>>
>>>
>>> for reference I've pasted it to pastebin.com:
>>>
>>> "2.6.37_zcache_V2.patch"
>>> http://pastebin.com/cVSkwQ6M
>>>
>>>
>>>
>>>
>>>
>>> after the reboot I had forgotten to not mount the btrfs volume and it
>>> threw a similar error-message again and remounted several partitions
>>> read-only (including the system partition)
>>> the partition with btrfs (/usr/gentoo) couldn't be unmounted since the
>>> umount process kind of hang
>>>
>>> so here's the error message after a reboot (might not be accurate or
>>> kind of "skewed" since other patches are included (io-less dirty
>>> throttling, PATCH] fix (latent?) memory corruption in
>>> btrfs_encode_fh() and latest changes for btrfs)) but might help to get
>>> some more evidence:
>>>
>>>
>>> Feb 14 02:05:46 lupus kernel: [ =A0 63.922648] device fsid
>>> 684a4213565dd3fe-ca991821badc2aac devid 1 transid 13
>>> /dev/mapper/portage
>>> Feb 14 02:05:46 lupus kernel: [ =A0 64.047118] btrfs: unlinked 1 orphan=
s
>>> Feb 14 02:05:46 lupus kernel: [ =A0 64.051956] zcache: created ephemera=
l
>>> tmem pool, id=3D3
>>> Feb 14 02:05:48 lupus kernel: [ =A0 65.801364] hub 2-1:1.0: hub_suspend
>>> Feb 14 02:05:48 lupus kernel: [ =A0 65.801376] usb 2-1: unlink
>>> qh256-0001/ffff88023fefd180 start 1 [1/0 us]
>>> Feb 14 02:05:48 lupus kernel: [ =A0 65.801559] usb 2-1: usb auto-suspen=
d
>>> Feb 14 02:05:50 lupus kernel: [ =A0 67.797929] hub 2-0:1.0: hub_suspend
>>> Feb 14 02:05:50 lupus kernel: [ =A0 67.797939] usb usb2: bus auto-suspe=
nd
>>> Feb 14 02:05:50 lupus kernel: [ =A0 67.797942] ehci_hcd 0000:00:1d.0:
>>> suspend root hub
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.050493] BUG: unable to handle
>>> kernel paging request at 0000030341ed0050
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.050670] IP: [<ffffffff8133ef1b>]
>>> btrfs_encode_fh+0x2b/0x120
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.050807] PGD 0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.050929] Oops: 0000 [#1] PREEMPT =
SMP
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.051223] last sysfs file:
>>> /sys/module/pcie_aspm/parameters/policy
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.051365] CPU 6
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.051411] Modules linked in:
>>> ipt_REJECT ipt_LOG xt_limit xt_tcpudp xt_state nf_nat_irc
>>> nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
>>> nf_conntrack_ftp iptable_filter ipt_addrtype xt_DSCP xt_dscp
>>> xt_iprange ip_tables ip6table_filter xt_NFQUEUE xt_owner xt_hashlimit
>>> xt_conntrack xt_mark xt_multiport xt_connmark nf_conntrack xt_string
>>> ip6_tables x_tables it87 hwmon_vid coretemp snd_seq_dummy snd_seq_oss
>>> snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss
>>> snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec
>>> snd_hwdep snd_pcm snd_timer snd i2c_i801 soundcore wmi shpchp e1000e
>>> snd_page_alloc libphy e1000 scsi_wait_scan sl811_hcd ohci_hcd ssb
>>> usb_storage ehci_hcd [last unloaded: tg3]
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.054694]
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.054776] Pid: 7962, comm: umount
>>> Not tainted 2.6.37-plus_v16_zcache #4 FMP55/ipower G3710
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.054912] RIP:
>>> 0010:[<ffffffff8133ef1b>] =A0[<ffffffff8133ef1b>]
>>> btrfs_encode_fh+0x2b/0x120
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055084] RSP:
>>> 0018:ffff88023c77d6f8 =A0EFLAGS: 00010246
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055173] RAX: 00000000000000ff
>>> RBX: ffff88023cde0168 RCX: 0000000000000000
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055265] RDX: ffff88023c77d734
>>> RSI: ffff88023c77d768 RDI: 0000000000000006
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055357] RBP: 0000030341ed0000
>>> R08: ffffffff8133eef0 R09: ffff88023c77d8d8
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055448] R10: 0000000000000003
>>> R11: 0000000000000001 R12: 00000000ffffffff
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055540] R13: ffff88023cde0030
>>> R14: ffffea0007dd39f0 R15: 0000000000000001
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055633] FS:
>>> 00007fb1cad04760(0000) GS:ffff8800bf580000(0000)
>>> knlGS:0000000000000000
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055762] CS: =A00010 DS: 0000 ES:
>>> 0000 CR0: 000000008005003b
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055851] CR2: 0000030341ed0050
>>> CR3: 000000023c7d5000 CR4: 00000000000006e0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.055943] DR0: 0000000000000000
>>> DR1: 0000000000000000 DR2: 0000000000000000
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.056035] DR3: 0000000000000000
>>> DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.056128] Process umount (pid:
>>> 7962, threadinfo ffff88023c77c000, task ffff88023c7a4260)
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.056257] Stack:
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.056338] =A00000000000000000
>>> 0000000000000002 ffff880200000000 0000000000000003
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.056630] =A0ffffea0007dd39f0
>>> ffffffff810e6aaa ffff880200000041 0000000600000246
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.056922] =A0ffff88023cdcd300
>>> ffffffff810e6b3a 0000000000000001 ffffffff8132bb7c
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057213] Call Trace:
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057301] =A0[<ffffffff810e6aaa>] =
?
>>> cleancache_get_key+0x4a/0x60
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057393] =A0[<ffffffff810e6b3a>] =
?
>>> __cleancache_get_page+0x7a/0xd0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057487] =A0[<ffffffff8132bb7c>] =
?
>>> merge_state+0x7c/0x150
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057579] =A0[<ffffffff8132e4de>] =
?
>>> __extent_read_full_page+0x52e/0x710
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057673] =A0[<ffffffff813bdea4>] =
?
>>> rb_insert_color+0xa4/0x140
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057766] =A0[<ffffffff8134b0b6>] =
?
>>> tree_insert+0x86/0x1e0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.057859] =A0[<ffffffff81058c73>] =
?
>>> lock_timer_base.clone.22+0x33/0x70
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058004] =A0[<ffffffff81305060>] =
?
>>> btree_get_extent+0x0/0x1c0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058097] =A0[<ffffffff81330b21>] =
?
>>> read_extent_buffer_pages+0x2d1/0x470
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058191] =A0[<ffffffff81305060>] =
?
>>> btree_get_extent+0x0/0x1c0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058283] =A0[<ffffffff8130674d>] =
?
>>> btree_read_extent_buffer_pages.clone.65+0x4d/0xa0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058415] =A0[<ffffffff813076f9>] =
?
>>> read_tree_block+0x39/0x60
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058508] =A0[<ffffffff812ed5e6>] =
?
>>> read_block_for_search.clone.40+0x116/0x410
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058638] =A0[<ffffffff812eb228>] =
?
>>> btrfs_cow_block+0x118/0x2b0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058731] =A0[<ffffffff812f0bc7>] =
?
>>> btrfs_search_slot+0x307/0xa00
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058823] =A0[<ffffffff812f6b18>] =
?
>>> lookup_inline_extent_backref+0x98/0x4a0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.058919] =A0[<ffffffff810e33d7>] =
?
>>> kmem_cache_alloc+0x87/0xa0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059032] =A0[<ffffffff812f891c>] =
?
>>> __btrfs_free_extent+0xcc/0x6f0
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059125] =A0[<ffffffff812fc4cf>] =
?
>>> run_clustered_refs+0x39f/0x880
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059220] =A0[<ffffffff810b1f98>] =
?
>>> pagevec_lookup_tag+0x18/0x20
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059312] =A0[<ffffffff810a7c81>] =
?
>>> filemap_fdatawait_range+0x91/0x180
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059405] =A0[<ffffffff812fca77>] =
?
>>> btrfs_run_delayed_refs+0xc7/0x220
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059498] =A0[<ffffffff8130c29c>] =
?
>>> btrfs_commit_transaction+0x7c/0x760
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059591] =A0[<ffffffff81067ea0>] =
?
>>> autoremove_wake_function+0x0/0x30
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059683] =A0[<ffffffff8130cdef>] =
?
>>> start_transaction+0x1bf/0x270
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059775] =A0[<ffffffff8110e96a>] =
?
>>> __sync_filesystem+0x5a/0x90
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059867] =A0[<ffffffff810eae8d>] =
?
>>> generic_shutdown_super+0x2d/0x100
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.059960] =A0[<ffffffff810eafb9>] =
?
>>> kill_anon_super+0x9/0x50
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.060051] =A0[<ffffffff810eb266>] =
?
>>> deactivate_locked_super+0x26/0x80
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.060144] =A0[<ffffffff811043ea>] =
?
>>> sys_umount+0x7a/0x390
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.060235] =A0[<ffffffff810027bb>] =
?
>>> system_call_fastpath+0x16/0x1b
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.060325] Code: 55 b8 ff 00 00 00
>>> 53 48 89 fb 48 83 ec 18 48 8b 6f 10 8b 3a 83 ff 04 0f 86 d5 00 00 00
>>> 85 c9 0f 95 c1 83 ff 07 0f 86 d5 00 00 00 <48> 8b 45 50 bf 05 00 00 00
>>> 48 89 06 84 c9 48 8b 85 68 fe ff ff
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.063170] RIP =A0[<ffffffff8133ef1=
b>]
>>> btrfs_encode_fh+0x2b/0x120
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.063302] =A0RSP <ffff88023c77d6f8=
>
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.063386] CR2: 0000030341ed0050
>>> Feb 14 02:05:52 lupus kernel: [ =A0 70.063528] ---[ end trace
>>> 3313552d105b1535 ]---
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.961960] BUG: unable to handle
>>> kernel paging request at 0000030341ed0050
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.962171] IP: [<ffffffff8133ef1b>]
>>> btrfs_encode_fh+0x2b/0x120
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.962307] PGD 0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.962430] Oops: 0000 [#2] PREEMPT =
SMP
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.962637] last sysfs file:
>>> /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.962766] CPU 5
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.962812] Modules linked in:
>>> ipt_REJECT ipt_LOG xt_limit xt_tcpudp xt_state nf_nat_irc
>>> nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
>>> nf_conntrack_ftp iptable_filter ipt_addrtype xt_DSCP xt_dscp
>>> xt_iprange ip_tables ip6table_filter xt_NFQUEUE xt_owner xt_hashlimit
>>> xt_conntrack xt_mark xt_multiport xt_connmark nf_conntrack xt_string
>>> ip6_tables x_tables it87 hwmon_vid coretemp snd_seq_dummy snd_seq_oss
>>> snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss
>>> snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec
>>> snd_hwdep snd_pcm snd_timer snd i2c_i801 soundcore wmi shpchp e1000e
>>> snd_page_alloc libphy e1000 scsi_wait_scan sl811_hcd ohci_hcd ssb
>>> usb_storage ehci_hcd [last unloaded: tg3]
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966044]
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966127] Pid: 7915, comm:
>>> btrfs-transacti Tainted: G =A0 =A0 =A0D =A0 =A0 2.6.37-plus_v16_zcache =
#4
>>> FMP55/ipower G3710
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966266] RIP:
>>> 0010:[<ffffffff8133ef1b>] =A0[<ffffffff8133ef1b>]
>>> btrfs_encode_fh+0x2b/0x120
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966440] RSP:
>>> 0018:ffff88023c63b6e0 =A0EFLAGS: 00010246
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966528] RAX: 00000000000000ff
>>> RBX: ffff88023cde0168 RCX: 0000000000000000
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966620] RDX: ffff88023c63b71c
>>> RSI: ffff88023c63b750 RDI: 0000000000000006
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966713] RBP: 0000030341ed0000
>>> R08: ffffffff8133eef0 R09: ffff88023c63b8c0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966805] R10: 0000000000000003
>>> R11: 0000000000000001 R12: 00000000ffffffff
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966897] R13: ffff88023cde0030
>>> R14: ffffea0007d59bc8 R15: 0000000000000001
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.966990] FS:
>>> 0000000000000000(0000) GS:ffff8800bf540000(0000)
>>> knlGS:0000000000000000
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.967120] CS: =A00010 DS: 0000 ES:
>>> 0000 CR0: 000000008005003b
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.967209] CR2: 0000030341ed0050
>>> CR3: 0000000001c27000 CR4: 00000000000006e0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.967302] DR0: 0000000000000000
>>> DR1: 0000000000000000 DR2: 0000000000000000
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.967394] DR3: 0000000000000000
>>> DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.967500] Process btrfs-transacti
>>> (pid: 7915, threadinfo ffff88023c63a000, task ffff88023c7a1620)
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.967630] Stack:
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.967711] =A00000000000000000
>>> 0000000000000002 0000000000000000 0000000000000003
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.968057] =A0ffffea0007d59bc8
>>> ffffffff810e6aaa 0000000000000041 0000000600000002
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.968348] =A00000000000000000
>>> ffffffff810e6b3a 0000000000000001 ffffffff00000001
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.968639] Call Trace:
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.968728] =A0[<ffffffff810e6aaa>] =
?
>>> cleancache_get_key+0x4a/0x60
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.968820] =A0[<ffffffff810e6b3a>] =
?
>>> __cleancache_get_page+0x7a/0xd0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.968914] =A0[<ffffffff8132e4de>] =
?
>>> __extent_read_full_page+0x52e/0x710
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969008] =A0[<ffffffff812f3f93>] =
?
>>> update_reserved_bytes+0xb3/0x140
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969102] =A0[<ffffffff81305060>] =
?
>>> btree_get_extent+0x0/0x1c0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969193] =A0[<ffffffff8132bb7c>] =
?
>>> merge_state+0x7c/0x150
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969285] =A0[<ffffffff81330b21>] =
?
>>> read_extent_buffer_pages+0x2d1/0x470
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969378] =A0[<ffffffff81305060>] =
?
>>> btree_get_extent+0x0/0x1c0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969470] =A0[<ffffffff8130674d>] =
?
>>> btree_read_extent_buffer_pages.clone.65+0x4d/0xa0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969602] =A0[<ffffffff813076f9>] =
?
>>> read_tree_block+0x39/0x60
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969694] =A0[<ffffffff812ed5e6>] =
?
>>> read_block_for_search.clone.40+0x116/0x410
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969878] =A0[<ffffffff812f0bc7>] =
?
>>> btrfs_search_slot+0x307/0xa00
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.969970] =A0[<ffffffff812f6b18>] =
?
>>> lookup_inline_extent_backref+0x98/0x4a0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970065] =A0[<ffffffff810e33d7>] =
?
>>> kmem_cache_alloc+0x87/0xa0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970157] =A0[<ffffffff812f891c>] =
?
>>> __btrfs_free_extent+0xcc/0x6f0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970249] =A0[<ffffffff812f8434>] =
?
>>> update_block_group.clone.62+0xc4/0x280
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970343] =A0[<ffffffff812fc4cf>] =
?
>>> run_clustered_refs+0x39f/0x880
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970436] =A0[<ffffffff812fca77>] =
?
>>> btrfs_run_delayed_refs+0xc7/0x220
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970529] =A0[<ffffffff810e15f9>] =
?
>>> new_slab+0x169/0x1f0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970619] =A0[<ffffffff8130c29c>] =
?
>>> btrfs_commit_transaction+0x7c/0x760
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970713] =A0[<ffffffff81067ea0>] =
?
>>> autoremove_wake_function+0x0/0x30
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970806] =A0[<ffffffff81305bc3>] =
?
>>> transaction_kthread+0x283/0x2a0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970898] =A0[<ffffffff81305940>] =
?
>>> transaction_kthread+0x0/0x2a0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.970990] =A0[<ffffffff81305940>] =
?
>>> transaction_kthread+0x0/0x2a0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.971083] =A0[<ffffffff81067a16>] =
?
>>> kthread+0x96/0xa0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.971174] =A0[<ffffffff81003514>] =
?
>>> kernel_thread_helper+0x4/0x10
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.971266] =A0[<ffffffff81067980>] =
?
>>> kthread+0x0/0xa0
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.971355] =A0[<ffffffff81003510>] =
?
>>> kernel_thread_helper+0x0/0x10
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.971444] Code: 55 b8 ff 00 00 00
>>> 53 48 89 fb 48 83 ec 18 48 8b 6f 10 8b 3a 83 ff 04 0f 86 d5 00 00 00
>>> 85 c9 0f 95 c1 83 ff 07 0f 86 d5 00 00 00 <48> 8b 45 50 bf 05 00 00 00
>>> 48 89 06 84 c9 48 8b 85 68 fe ff ff
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.974280] RIP =A0[<ffffffff8133ef1=
b>]
>>> btrfs_encode_fh+0x2b/0x120
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.974412] =A0RSP <ffff88023c63b6e0=
>
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.974497] CR2: 0000030341ed0050
>>> Feb 14 02:06:16 lupus kernel: [ =A0 93.974599] ---[ end trace
>>> 3313552d105b1536 ]---
>>> Feb 14 02:07:04 lupus kernel: [ =A0141.906124] zcache: destroyed pool i=
d=3D2
>>> Feb 14 02:07:17 lupus kernel: [ =A0154.783358] SysRq : Keyboard mode se=
t
>>> to system default
>>> Feb 14 02:07:18 lupus kernel: [ =A0155.486147] SysRq : Terminate All Ta=
sks
>>>
>>>
>>> That's all for now
>>>
>>> Thanks & Regards
>>>
>>> Matt
>>>
>>
>> (leaving out several folks from the CC to avoid spamming - if I left
>> out someone wrongfully please re-add)
>>
>> running an addr2line reveals:
>>
>>
>> addr2line -e /usr/src/linux-2.6.37_vanilla/vmlinux -i ffffffff81338cbb
>> export.c:0
>>
>>
>> hope that helps
>>
>>
>> Regards
>>
>> Matt
>>
>
> Just my guessing. I might be wrong.
>
> __cleancache_flush_inode calls cleancache_get_key with cleancache_filekey=
