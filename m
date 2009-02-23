Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF58E6B0099
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 06:42:24 -0500 (EST)
Date: Mon, 23 Feb 2009 11:42:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/20] Inline get_page_from_freelist() in the fast-path
Message-ID: <20090223114221.GD6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-12-git-send-email-mel@csn.ul.ie> <84144f020902222321q12f54ed8wae3865064bb6e43@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <84144f020902222321q12f54ed8wae3865064bb6e43@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 09:21:09AM +0200, Pekka Enberg wrote:
> On Mon, Feb 23, 2009 at 1:17 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > In the best-case scenario, use an inlined version of
> > get_page_from_freelist(). This increases the size of the text but avoids
> > time spent pushing arguments onto the stack.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> It's not obvious to me why this would be a huge win so I suppose this
> patch description could use numbers.

I don't have the exact numbers from the profiles any more but the
function entry and exit was about 1/20th of the cost of the path when
zeroing pages is not taken into account.

> Note: we used to do tricks like
> these in slab.c but got rid of most of them to reduce kernel text size
> which is probably why the patch seems bit backwards to me.
> 

I'll be rechecking this patch in particular because it's likely the
biggest text bloat in the entire series.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
