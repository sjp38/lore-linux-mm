Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AA3E56B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:31:44 -0400 (EDT)
Date: Fri, 22 Jul 2011 14:31:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 8/8] mm: vmscan: Do not writeback filesystem pages from
 kswapd
Message-ID: <20110722133138.GY5349@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-9-git-send-email-mgorman@suse.de>
 <1311339432.27400.36.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311339432.27400.36.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Fri, Jul 22, 2011 at 02:57:12PM +0200, Peter Zijlstra wrote:
> On Thu, 2011-07-21 at 17:28 +0100, Mel Gorman wrote:
> > Assuming that flusher threads will always write back dirty pages promptly
> > then it is always faster for reclaimers to wait for flushers. This patch
> > prevents kswapd writing back any filesystem pages. 
> 
> That is a somewhat sort changelog for such a big assumption ;-)
> 

That is an understatement but the impact of the patch is discussed in
detail in the leader. On NUMA, this patch has a negative impact so
I put no effort into the changelog. The patch is part of the series
because it was specifically asked for.

> I think it can use a few extra words to explain the need to clean pages
> from @zone vs writeback picks whatever fits best on disk and how that
> works out wrt the assumption.
> 

At the time of writing the changelog, I knew that flushers were
not finding pages from the correct zones quickly enough in the NUMA
usecase. The changelog documents the assumptions testing shows them to
be false.

> What requirements does this place on writeback and how does it meet
> them.

It places a requirement on writeback to prioritise pages from zones
under memory pressure. It doesn't meet them. I mention in the leader
that I think patch 8 should be dropped which is why the changelog
sucks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
