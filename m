Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8AB5E900086
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 06:38:40 -0400 (EDT)
Date: Tue, 19 Apr 2011 16:38:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/6] writeback: moving expire targets for
 background/kupdate works
Message-ID: <20110419063823.GD23985@dastard>
References: <20110419030003.108796967@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419030003.108796967@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 19, 2011 at 11:00:03AM +0800, Wu Fengguang wrote:
> 
> Andrew,
> 
> This aims to reduce possible pageout() calls by making the flusher
> concentrate a bit more on old/expired dirty inodes.

In what situation is this a problem? Can you demonstrate how you
trigger it? And then how much improvement does this patchset make?

> Patches 04, 05 have been updated since last post, please review.
> The concerns from last review have been addressed.
> 
> It runs fine on simple workloads over ext3/4, xfs, btrfs and NFS.

But it starts propagating new differences between background and
kupdate style writeback. We've been trying to reduce the number of
permutations of writeback behaviour, so it seems to me to be wrong
to further increase the behavioural differences. Indeed, why do we
need "for kupdate" style writeback and "background" writeback
anymore - can' we just use background style writeback for both?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
