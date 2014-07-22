Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id E2FB06B0036
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 18:14:40 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so406572qgf.20
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:14:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si789975qar.32.2014.07.22.15.14.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jul 2014 15:14:40 -0700 (PDT)
Date: Tue, 22 Jul 2014 18:14:21 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: slab_common: fix the check for duplicate slab names
Message-ID: <20140722221421.GA11318@redhat.com>
References: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com>
 <20140325170324.GC580@redhat.com>
 <alpine.DEB.2.10.1403251306260.26471@nuc>
 <20140523201632.GA16013@redhat.com>
 <537FBD6F.1070009@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537FBD6F.1070009@iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Zdenek Kabelac <zkabelac@redhat.com>

On Fri, May 23 2014 at  5:28pm -0400,
Pekka Enberg <penberg@iki.fi> wrote:

> On 05/23/2014 11:16 PM, Mike Snitzer wrote:
> >On Tue, Mar 25 2014 at  2:07pm -0400,
> >Christoph Lameter <cl@linux.com> wrote:
> >
> >>On Tue, 25 Mar 2014, Mike Snitzer wrote:
> >>
> >>>This patch still isn't upstream.  Who should be shepherding it to Linus?
> >>Pekka usually does that.
> >>
> >>Acked-by: Christoph Lameter <cl@linux.com>
> >This still hasn't gotten upstream.
> >
> >Pekka, any chance you can pick it up?  Here it is in dm-devel's
> >kernel.org patchwork: https://patchwork.kernel.org/patch/3768901/
> >
> >(Though it looks like it needs to be rebased due to the recent commit
> >794b1248, should Mikulas rebase and re-send?)
> 
> I applied it and fixed the conflict by hand.
> 
> Please double-check commit 694617474e33b8603fc76e090ed7d09376514b1a
> in my tree:
> 
> https://git.kernel.org/cgit/linux/kernel/git/penberg/linux.git/

Pekka, this clearly still hasn't landed for 3.16.  Can you please get
it upstream ASAP?  It is a lingering issue that keeps rearing its ugly
head, latest report on Fedora rawhide:

3,2059,887335968,-;kmem_cache_sanity_check (raid5-ffff880074a56010): Cache name already exists.
4,2060,887339337,-;CPU: 1 PID: 12874 Comm: lvm Not tainted 3.16.0-0.rc4.git1.1.fc21.x86_64 #1
4,2061,887342267,-;Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
4,2062,887344959,-; 0000000000000000 00000000808b098a ffff880074d23a00 ffffffff81807d5c
4,2063,887347591,-; ffff88007557ab48 ffff880074d23a78 ffffffff811e9451 ffff88007557a800
4,2064,887350230,-; ffff880074d23a78 0000000000000000 0000000000000000 0000000000000690
4,2065,887352882,-;Call Trace:
4,2066,887355210,-; [<ffffffff81807d5c>] dump_stack+0x4d/0x66
4,2067,887357157,-; [<ffffffff811e9451>] kmem_cache_create+0x2c1/0x330
4,2068,887360103,-; [<ffffffffa0272527>] setup_conf+0x677/0x8c0 [raid456]
4,2069,887362901,-; [<ffffffff810e1d78>] ? sched_clock_cpu+0x98/0xc0
4,2070,887364749,-; [<ffffffffa0273350>] run+0x8c0/0xab0 [raid456]
4,2071,887366545,-; [<ffffffff8162f562>] md_run+0x562/0x980
4,2072,887368240,-; [<ffffffffa028756c>] ? raid_ctr+0xf3c/0x13f8 [dm_raid]
4,2073,887370163,-; [<ffffffff810fbc44>] ? static_obj+0x34/0x50
4,2074,887371973,-; [<ffffffff810fc4ac>] ? lockdep_init_map+0x6c/0x570
4,2075,887373889,-; [<ffffffffa0287578>] raid_ctr+0xf48/0x13f8 [dm_raid]
4,2076,887375849,-; [<ffffffff8163c5b0>] dm_table_add_target+0x160/0x3b0
4,2077,887377816,-; [<ffffffff8163fb14>] table_load+0x144/0x360
4,2078,887379645,-; [<ffffffff8163f9d0>] ? retrieve_status+0x1c0/0x1c0
4,2079,887381536,-; [<ffffffff816407db>] ctl_ioctl+0x25b/0x550
4,2080,887383318,-; [<ffffffff81640ae3>] dm_ctl_ioctl+0x13/0x20
4,2081,887385130,-; [<ffffffff812628e0>] do_vfs_ioctl+0x2f0/0x520
4,2082,887387025,-; [<ffffffff8126f2bd>] ? __fget_light+0x13d/0x160
4,2083,887388895,-; [<ffffffff81262b91>] SyS_ioctl+0x81/0xa0
4,2084,887390694,-; [<ffffffff8115fbac>] ? __audit_syscall_entry+0x9c/0xf0
4,2085,887392656,-; [<ffffffff81811969>] system_call_fastpath+0x16/0x1b
4,2086,887394585,-;kmem_cache_create(raid5-ffff880074a56010) failed with error -22
4,2087,887395592,-;CPU: 1 PID: 12874 Comm: lvm Not tainted 3.16.0-0.rc4.git1.1.fc21.x86_64 #1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
