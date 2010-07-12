Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CDC0F6B02A4
	for <linux-mm@kvack.org>; Sun, 11 Jul 2010 22:52:50 -0400 (EDT)
Date: Sun, 11 Jul 2010 22:52:47 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/5] Per superblock shrinkers V2
Message-ID: <20100712025247.GA16784@infradead.org>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <20100702121304.GA10075@infradead.org>
 <20100712024104.GD25335@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712024104.GD25335@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, Jul 12, 2010 at 12:41:04PM +1000, Dave Chinner wrote:
> At this point in the cycle, I'd much prefer just to go with adding a
> context to the shrinker API to fix the XFS locking issues (i.e.  the
> original patches I sent) and spend a bit more time working out which
> combination of Nick's and my bits that improves reclaim speed whilst
> retaining the stability of the courrent code....

That approach sounds good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
