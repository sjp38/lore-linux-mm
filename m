Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 99B256B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 20:06:11 -0400 (EDT)
Date: Tue, 27 Apr 2010 10:05:39 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Locking between writeback and truncate paths?
Message-ID: <20100427000539.GA9783@dastard>
References: <E1O6CFc-0006Y2-SY@closure.thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1O6CFc-0006Y2-SY@closure.thunk.org>
Sender: owner-linux-mm@kvack.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 25, 2010 at 08:32:40PM -0400, Theodore Ts'o wrote:
> Any thoughts or suggestions would be greatly appreciated.  I've looked
> at the xfs and btrfs code for some ideas, but dealing with current
> writeback and truncate is nasty, especially if there's a subsequent
> delalloc write happening in parallel with the writeback and immediately
> after the truncate.  After studying the code quite extensively over the
> weekend, I'm still not entirely sure that XFS and btrfs gets this case
> right (I know ext4 currently doesn't).  Of course, it's not clear
> whether users will trip against this in practice, but it's nevertheless
> still a botch, and I'm wondering if it's simpler to avoid the concurrent
> vmtruncate/writeback case entirely.

What case are you concerned that is XFS not getting right?

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
