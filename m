Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1E0BC600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 00:07:37 -0400 (EDT)
Date: Thu, 27 May 2010 14:07:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/5] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100527040704.GJ12087@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100526164116.GD22536@laptop>
 <20100526231214.GB1395@dastard>
 <20100527021905.GG22536@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100527021905.GG22536@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 12:19:05PM +1000, Nick Piggin wrote:
> On Thu, May 27, 2010 at 09:12:14AM +1000, Dave Chinner wrote:
> > On Thu, May 27, 2010 at 02:41:16AM +1000, Nick Piggin wrote:
> > > > +	count = ((sb->s_nr_dentry_unused + sb->s_nr_inodes_unused) / 100)
> > > > +						* sysctl_vfs_cache_pressure;
> > > 
> > > Do you think truncating in the divisions is at all a problem? It
> > > probably doesn't matter much I suppose.
> > 
> > Same code as currently exists. IIRC, the reasoning is that if we've
> > got less that 100 objects to reclaim, then we're unlikely to be able
> > to free up any memory from the caches, anyway.
> 
> Yeah, which is why I stop short of saying you should change it in
> this patch.
> 
> But I think we should ensure things can get reclaimed eventually.
> 100 objects could be 100 slabs, which could be anything from
> half a meg to half a dozen. Multiplied by each of the caches.
> Could be significant in small systems.

True, but usually there are busy objects in the dentry and inode
slabs, so it shouldn't be a significant issue. We can probably
address such problems if they can be demonstrated to be an issue in
a separate patch set....

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
