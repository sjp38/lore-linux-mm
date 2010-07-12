Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DF8266B024D
	for <linux-mm@kvack.org>; Sun, 11 Jul 2010 22:41:13 -0400 (EDT)
Date: Mon, 12 Jul 2010 12:41:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/5] Per superblock shrinkers V2
Message-ID: <20100712024104.GD25335@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <20100702121304.GA10075@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100702121304.GA10075@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 08:13:04AM -0400, Christoph Hellwig wrote:
> Did you plan to resubmit this with the few review comments addressed?
> I'd really hate to not see this in 2.6.36.

I've been doing some more testing on it, and while I can get a 25%
reduction in the time to create and remove 10 million inodes with
per-sb shrinker, I can't get the reclaim pattern stable enough for
my liking.

At this point in the cycle, I'd much prefer just to go with adding a
context to the shrinker API to fix the XFS locking issues (i.e.  the
original patches I sent) and spend a bit more time working out which
combination of Nick's and my bits that improves reclaim speed whilst
retaining the stability of the courrent code....

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
