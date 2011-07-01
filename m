Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B40AF6B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 11:15:18 -0400 (EDT)
Date: Fri, 1 Jul 2011 11:15:09 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110701151509.GA30620@infradead.org>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701145935.GB29530@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110701145935.GB29530@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, jack@suse.cz, linux-mm@kvack.org

On Fri, Jul 01, 2011 at 03:59:35PM +0100, Mel Gorman wrote:
> On Fri, Jul 01, 2011 at 05:33:05AM -0400, Christoph Hellwig wrote:
> > Johannes, Mel, Wu,
> 
> Am adding Jan Kara as he has been working on writeback efficiency
> recently as well.
> 
> > Dave has been stressing some XFS patches of mine that remove the XFS
> > internal writeback clustering in favour of using write_cache_pages.
> > 
> 
> Against what kernel? 2.6.38 was a disaster for reclaim I've been
> finding out this week. I don't know about 2.6.38.8. 2.6.39 was better.

The patch series is against current 3.0-rc, I assume that's what Dave
tested as well.

> I'm assuming "test 180" is from xfstests which was not one of the tests
> I used previously. To run with 1000 files instead of 100, was the file
> "180" simply editted to make it look like this loop instead?

Yes. to both questions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
