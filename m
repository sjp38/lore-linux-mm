Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C83B96B02A7
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 20:21:14 -0400 (EDT)
Date: Sat, 24 Jul 2010 10:21:01 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: VFS scalability git tree
Message-ID: <20100724002101.GL32635@dastard>
References: <20100722190100.GA22269@amd>
 <20100723111310.GI32635@dastard>
 <20100723155118.GB5773@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723155118.GB5773@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 24, 2010 at 01:51:18AM +1000, Nick Piggin wrote:
> On Fri, Jul 23, 2010 at 09:13:10PM +1000, Dave Chinner wrote:
> > On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> > > I'm pleased to announce I have a git tree up of my vfs scalability work.
> > > 
> > > git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> > > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> > > 
> > > Branch vfs-scale-working
> > 
> > I've got a couple of patches needed to build XFS - they shrinker
> > merge left some bad fragments - I'll post them in a minute. This
> 
> OK cool.
> 
> 
> > email is for the longest ever lockdep warning I've seen that
> > occurred on boot.
> 
> Ah thanks. OK that was one of my attempts to keep sockets out of
> hidding the vfs as much as possible (lazy inode number evaluation).
> Not a big problem, but I'll drop the patch for now.
> 
> I have just got one for you too, btw :) (on vanilla kernel but it is
> messing up my lockdep stress testing on xfs). Real or false?
> 
> [ INFO: possible circular locking dependency detected ]
> 2.6.35-rc5-00064-ga9f7f2e #334
> -------------------------------------------------------
> kswapd0/605 is trying to acquire lock:
>  (&(&ip->i_lock)->mr_lock){++++--}, at: [<ffffffff8125500c>]
> xfs_ilock+0x7c/0xa0
> 
> but task is already holding lock:
>  (&xfs_mount_list_lock){++++.-}, at: [<ffffffff81281a76>]
> xfs_reclaim_inode_shrink+0xc6/0x140

False positive, but the xfs_mount_list_lock is gone in 2.6.35-rc6 -
the shrinker context change has fixed that - so you can ignore it
anyway.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
