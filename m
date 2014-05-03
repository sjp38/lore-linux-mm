Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id 957936B0036
	for <linux-mm@kvack.org>; Sat,  3 May 2014 15:24:14 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id jz11so3218711veb.21
        for <linux-mm@kvack.org>; Sat, 03 May 2014 12:24:14 -0700 (PDT)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id tv3si620885vdc.54.2014.05.03.12.24.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 03 May 2014 12:24:13 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id hy4so6780054vcb.40
        for <linux-mm@kvack.org>; Sat, 03 May 2014 12:24:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFLxGvxZxWf6nzJ5cXM--b02axz9u8UL_MTUyo3WgLPvbpCFAg@mail.gmail.com>
References: <20140415190936.GA24654@redhat.com>
	<alpine.LSU.2.11.1404161239320.6778@eggly.anvils>
	<CAFLxGvxZxWf6nzJ5cXM--b02axz9u8UL_MTUyo3WgLPvbpCFAg@mail.gmail.com>
Date: Sat, 3 May 2014 21:24:13 +0200
Message-ID: <CAFLxGvxPV9+BgP=CVEp4kLbedOYBEui9uYddNTDix=ENrrusoQ@mail.gmail.com>
Subject: Re: [3.15rc1] BUG at mm/filemap.c:202!
From: Richard Weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 1, 2014 at 6:20 PM, Richard Weinberger
<richard.weinberger@gmail.com> wrote:
> On Wed, Apr 16, 2014 at 10:40 PM, Hugh Dickins <hughd@google.com> wrote:
>> On Tue, 15 Apr 2014, Dave Jones wrote:
>>
>>> kernel BUG at mm/filemap.c:202!
>>> invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>> Modules linked in: tun fuse bnep rfcomm nfnetlink llc2 af_key ipt_ULOG can_raw can_bcm scsi_transport_iscsi nfc caif_socket caif af_802154 ieee802154 phonet af_r
>>> xrpc can pppoe pppox ppp_generic slhc irda crc_ccitt rds rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 cfg80211 coretemp hwmon x86_pkg_temp_thermal kvm_intel kvm
>>>  xfs libcrc32c snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic crct10dif_pclmul crc32c_intel ghash_clmulni_intel snd_hda_intel snd_hda_controller snd_hda_codec e
>>> 1000e btusb bluetooth microcode pcspkr serio_raw snd_hwdep snd_seq snd_seq_device snd_pcm 6lowpan_iphc usb_debug rfkill ptp pps_core shpchp snd_timer snd soundcore
>>> CPU: 3 PID: 14244 Comm: trinity-main Not tainted 3.15.0-rc1+ #188
>>> task: ffff8801be2c50a0 ti: ffff8801d6830000 task.ti: ffff8801d6830000
>>> RIP: 0010:[<ffffffff9915b4d5>]  [<ffffffff9915b4d5>] __delete_from_page_cache+0x315/0x320
>>> RSP: 0018:ffff8801d6831b10  EFLAGS: 00010046
>>> RAX: 0000000000000000 RBX: 0000000000000003 RCX: 000000000000001d
>>> RDX: 000000000000012a RSI: ffffffff99a9a1c0 RDI: ffffffff99a6dad5
>>> RBP: ffff8801d6831b60 R08: 000000000000005d R09: ffff8801b0361530
>>> R10: ffff8801d6831b28 R11: 0000000000000000 R12: ffffea000734d440
>>> R13: ffff880241235008 R14: 0000000000000000 R15: ffff880241235010
>>> FS:  00007f81925cf740(0000) GS:ffff880244600000(0000) knlGS:0000000000000000
>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> CR2: 0000000000630058 CR3: 0000000019c0e000 CR4: 00000000001407e0
>>> DR0: 0000000000df3000 DR1: 0000000000000000 DR2: 0000000000000000
>>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
>>> Stack:
>>>  ffff880241235020 ffff880241235038 ffff8801b0361530 ffff8801b0361640
>>>  000000001da16adc ffffea000734d440 ffff880241235020 0000000000000000
>>>  0000000000000000 000000000000005d ffff8801d6831b88 ffffffff9915b51d
>>> Call Trace:
>>>  [<ffffffff9915b51d>] delete_from_page_cache+0x3d/0x70
>>>  [<ffffffff9916ab7b>] truncate_inode_page+0x5b/0x90
>>>  [<ffffffff991759ab>] shmem_undo_range+0x30b/0x780
>>>  [<ffffffff990a99e5>] ? local_clock+0x25/0x30
>>>  [<ffffffff99175e34>] shmem_truncate_range+0x14/0x30
>>>  [<ffffffff99175f1d>] shmem_evict_inode+0xcd/0x150
>>>  [<ffffffff991e46e7>] evict+0xa7/0x170
>>>  [<ffffffff991e5005>] iput+0xf5/0x180
>>>  [<ffffffff991df390>] dentry_kill+0x210/0x250
>>>  [<ffffffff991df43c>] dput+0x6c/0x110
>>>  [<ffffffff991c8c19>] __fput+0x189/0x200
>>>  [<ffffffff991c8cde>] ____fput+0xe/0x10
>>>  [<ffffffff990900b4>] task_work_run+0xb4/0xe0
>>>  [<ffffffff9906ea92>] do_exit+0x302/0xb80
>>>  [<ffffffff99349843>] ? __this_cpu_preempt_check+0x13/0x20
>>>  [<ffffffff9907038c>] do_group_exit+0x4c/0xc0
>>>  [<ffffffff99070414>] SyS_exit_group+0x14/0x20
>>>  [<ffffffff9975a964>] tracesys+0xdd/0xe2
>>> Code: 4c 89 30 e9 80 fe ff ff 48 8b 75 c0 4c 89 ff e8 e2 8e 1c 00 84 c0 0f 85 6c fe ff ff e9 4f fe ff ff 0f 1f 44 00 00 e8 4e 85 5e 00 <0f> 0b e8 84 1d f1 ff 0f :
>>>
>>>
>>>  202         BUG_ON(page_mapped(page));
>>
>> I've been wrestling with this report, but made no progress;
>> maybe if I set down a few thoughts, someone can help us forward.
>>
>> It is reasonable to assume (but unreasonable to hold on too tightly
>> to the assumption) that this is related to Dave's contemporaneous
>> report of BUG: Bad rss-counter state mm:ffff88023fc73c00 idx:0 val:5
>>
>> I don't know if they both occurred in the same session; but whether
>> or not they did, the BUG_ON(page_mapped(page)) from inode eviction
>> implies that not every pte mapping a shmem file page had been located
>> when its last mapper exited; and the rss-counter message implies that
>> there were five pte mappings of file(s) which could not be located
>> when their mapper exited.
>>
>> It is also reasonable to assume (but unreasonable to hold on too
>> tightly to the assumption) that this is another manifestation of
>> the same unsolved mm/filemap.c:202 that Sasha reported on rc5-next
>> a month ago, https://lkml.org/lkml/2014/3/7/298
>>
>> Now that one occurred, not while evicting a shmem inode, but while
>> punching a hole in it with madvise(,,MADV_REMOVE).  At the time I
>> set it aside to consider when improving shmem_fallocate(), but now
>> it looks more like a precursor of Dave's.
>>
>> One way this could happen is if we have racing tasks setting up
>> ptes without the necessary locking, one placing its pte on top of
>> another's, so page_mapcount goes up by 2 but comes down by 1 later.
>> But I failed to find anywhere in the code in danger of doing that.
>>
>> Another way it could happen is if a vma is removed from i_mmap tree
>> and i_mmap_nonlinear list, without zap_pte_range() having zapped all
>> of its ptes; but I don't see where that could happen either.
>>
>> Sasha's came before shmem participated in Kirill's filemap_map_pages
>> fault-around; but his pte_same/pte_none checking under ptl there looks
>> correct anyway.  I've not found any recent change likely to blame.
>>
>> Help!
>
> Using a trinity as of today I'm able to trigger this bug on UML within seconds.
> If you want me to test patch, I can help.
>
> I'm also observing one strange fact, I can trigger this on any kernel version.
> So far I've managed UML to crash on 3.0 to 3.15-rc...

After digging deeper into UML's mmu and tlb code I've found issues and
fixed them.

But I'm still facing this issue. Although triggering the BUG_ON() is
not so easy as before
I can trigger "BUG: Bad rss-counter ..." very easily.
Now the interesting fact, with my UML mmu and flb fixes applied it
happens only on kernels >= 3.14.
If it helps I can try to bisect it.

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
