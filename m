Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 21AEE6B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 10:18:18 -0400 (EDT)
Date: Wed, 3 Aug 2011 10:18:07 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/8] ext4: Warn if direct reclaim tries to writeback pages
Message-ID: <20110803141807.GA7676@infradead.org>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-4-git-send-email-mgorman@suse.de>
 <20110803105819.GA27199@redhat.com>
 <20110803110629.GB27199@redhat.com>
 <20110803134420.GH19099@suse.de>
 <20110803140019.GA31026@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110803140019.GA31026@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, josef@redhat.com

On Wed, Aug 03, 2011 at 04:00:19PM +0200, Johannes Weiner wrote:
> > That said, in my current revision of the series, I've dropped these
> > patches altogether as page migration should be able to trigger the same
> > warnings but be called from paths that are of less concern for stack
> > overflows (or at the very least be looked at as a separate series).
> 
> Doesn't this only apply to btrfs which has no own .migratepage aop for
> file pages?  The others use buffer_migrate_page.
> 
> But if you dropped them anyway, it does not matter :)

Note that the mid-term plan is to kill ->writepage as an address space
method.  Besides the usage from reclaim as as callbacks to
write_cache_pages and write_one_page (which can be made explicit
arguments) the only remaining user is the above mentioned fallback.

Josef, any chance you could switch btrfs over to implement a proper
->migratepage?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
