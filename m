Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 87D18600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 14:31:19 -0400 (EDT)
Date: Mon, 2 Aug 2010 20:31:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100802183109.GJ3278@quack.suse.cz>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
 <1280497020-22816-7-git-send-email-mel@csn.ul.ie>
 <20100730150601.199c5618.akpm@linux-foundation.org>
 <20100731103321.GI3571@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100731103321.GI3571@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat 31-07-10 11:33:22, Mel Gorman wrote:
> On Fri, Jul 30, 2010 at 03:06:01PM -0700, Andrew Morton wrote:
> > Sigh.  We have sooo many problems with writeback and latency.  Read
> > https://bugzilla.kernel.org/show_bug.cgi?id=12309 and weep.
> 
> You aren't joking.
> 
> > Everyone's
> > running away from the issue and here we are adding code to solve some
> > alleged stack-overflow problem which seems to be largely a non-problem,
> > by making changes which may worsen our real problems.
> > 
> 
> As it is, filesystems are beginnning to ignore writeback from direct
> reclaim - such as xfs and btrfs. I'm lead to believe that ext3
> effectively ignores writeback from direct reclaim although I don't have
> access to code at the moment to double check (am on the road). So either
> way, we are going to be facing this problem so the VM might as well be
> aware of it :/
  Umm, ext3 should be handling direct reclaim just fine. ext4 does however
ignore it when a page does not have block already allocated (which is a
common case with delayed allocation).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
