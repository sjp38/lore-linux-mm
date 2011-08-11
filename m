Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 358306B016A
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 19:45:23 -0400 (EDT)
Date: Thu, 11 Aug 2011 19:45:16 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/7] Reduce filesystem writeback from page reclaim v3
Message-ID: <20110811234516.GA21649@infradead.org>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
 <20110810110056.GA31756@infradead.org>
 <20110810111547.GZ19099@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110810111547.GZ19099@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <jweiner@redhat.com>

On Wed, Aug 10, 2011 at 12:15:47PM +0100, Mel Gorman wrote:
> > The right fix is to simply remove that fallback, possibly in combination
> > with implementating real migration support for btrfs.
> > 
> 
> Removing the fallback entirely is overkill as proper migration support
> is not going to get 100% coverage

It seems like btrfs is indeed the only important one missing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
