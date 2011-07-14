Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A46CA6B007E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 00:51:27 -0400 (EDT)
Date: Thu, 14 Jul 2011 00:51:23 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 0/5] Reduce filesystem writeback from page reclaim
 (again)
Message-ID: <20110714045123.GB3203@infradead.org>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <20110714003340.GZ23038@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714003340.GZ23038@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 10:33:40AM +1000, Dave Chinner wrote:
> patchset. After all, that's what I keep asking for (so we can get
> rid of .writepage altogether), and if the numbers don't add up, then
> I'll shut up about it. ;)

Unfortunately there's a few more users of ->writepage in addition to
memory reclaim.  The most visible on is page migration, but there's also
a write_one_page helper used by a few filesystems that would either
need to get a writepage-like callback or a bigger rewrite.

I agree that killing of ->writepage would be a worthwhile goal, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
