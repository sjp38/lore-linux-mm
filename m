Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF09E6B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 06:52:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 123so7545660wmb.7
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 03:52:48 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id z68si2591254wmz.19.2016.10.07.03.52.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 03:52:47 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 123so2350440wmb.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 03:52:47 -0700 (PDT)
Date: Fri, 7 Oct 2016 12:52:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: lockdep splat due to reclaim recursion detected
Message-ID: <20161007105245.GK18439@dhcp22.suse.cz>
References: <20161007080739.GD18439@dhcp22.suse.cz>
 <20161007081340.GF18439@dhcp22.suse.cz>
 <20161007103039.GJ9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161007103039.GJ9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 07-10-16 21:30:39, Dave Chinner wrote:
> On Fri, Oct 07, 2016 at 10:13:40AM +0200, Michal Hocko wrote:
> > Fix up xfs ML address
> > 
> > On Fri 07-10-16 10:07:39, Michal Hocko wrote:
> > > Hi Dave,
> > > while playing with the test case you have suggested [1], I have hit the
> > > following lockdep splat. This is with mmotm git tree [2] but I didn't
> > > get to retest with the current linux-next (or any other tree of your
> > > preference) so there is a chance that something is broken in my tree so
> > > take this as a heads up. As soon as I am done with testing of the patch
> > > in the above email thread I will retest with linux-next.
> ....
> > > [   61.878792] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
> > > [   61.878792]  0000000000000000 ffff88001c8b3718 ffffffff81312f78 ffffffff825d99d0
> > > [   61.878792]  ffff88001cd04880 ffff88001c8b3750 ffffffff811260d1 000000000000000a
> > > [   61.878792]  ffff88001cd05178 ffff88001cd04880 ffffffff81095395 ffff88001cd04880
> > > [   61.878792] Call Trace:
> > > [   61.878792]  [<ffffffff81312f78>] dump_stack+0x68/0x92
> > > [   61.878792]  [<ffffffff811260d1>] print_usage_bug.part.26+0x25b/0x26a
> > > [   61.878792]  [<ffffffff81095395>] ? print_shortest_lock_dependencies+0x17f/0x17f
> > > [   61.878792]  [<ffffffff81096074>] mark_lock+0x381/0x56d
> > > [   61.878792]  [<ffffffff810962be>] mark_held_locks+0x5e/0x74
> > > [   61.878792]  [<ffffffff8109875c>] lockdep_trace_alloc+0xaf/0xb2
> > > [   61.878792]  [<ffffffff8117d0f7>] kmem_cache_alloc_trace+0x3a/0x270
> > > [   61.878792]  [<ffffffff81169454>] ? vm_map_ram+0x2d2/0x4a6
> > > [   61.878792]  [<ffffffff8116924b>] ? vm_map_ram+0xc9/0x4a6
> > > [   61.878792]  [<ffffffff81169454>] vm_map_ram+0x2d2/0x4a6
> > > [   61.878792]  [<ffffffffa0051069>] _xfs_buf_map_pages+0xae/0x10b [xfs]
> > > [   61.878792]  [<ffffffffa0052cd0>] xfs_buf_get_map+0xaa/0x24f [xfs]
> > > [   61.878792]  [<ffffffffa0081d10>] xfs_trans_get_buf_map+0x144/0x2ef [xfs]
> 
> Aw, come on! I explained this lockdep annotation bug a couple of
> days ago.
> 
> https://www.spinics.net/lists/linux-fsdevel/msg102588.html

Ohh, I have missed that one. I have only seen one message from that
thread which landed in my inbox but didn't get to see the full thread.
Sorry about the noise then!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
