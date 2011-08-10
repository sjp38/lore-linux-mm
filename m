Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AA6046B0173
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 07:15:52 -0400 (EDT)
Date: Wed, 10 Aug 2011 12:15:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7] Reduce filesystem writeback from page reclaim v3
Message-ID: <20110810111547.GZ19099@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
 <20110810110056.GA31756@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110810110056.GA31756@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, Aug 10, 2011 at 07:00:56AM -0400, Christoph Hellwig wrote:
> On Wed, Aug 10, 2011 at 11:47:13AM +0100, Mel Gorman wrote:
> >   o Dropped btrfs warning when filesystems are called from direct
> >     reclaim. The fallback method for migration looks indistinguishable
> >     from direct reclaim.
> 
> The right fix is to simply remove that fallback, possibly in combination
> with implementating real migration support for btrfs.
> 

Removing the fallback entirely is overkill as proper migration support
is not going to get 100% coverage but I agree that btrfs should have
real migration support. I didn't think it belonged in this series
though.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
