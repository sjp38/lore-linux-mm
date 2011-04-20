Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B07ED8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 12:40:45 -0400 (EDT)
Date: Wed, 20 Apr 2011 12:39:54 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] mm/vmalloc: remove block allocation bitmap
Message-ID: <20110420163954.GA7297@infradead.org>
References: <20110414211656.GB1700@cmpxchg.org>
 <20110419093118.GB23041@csn.ul.ie>
 <20110419233905.GA2333@cmpxchg.org>
 <20110420094647.GB1306@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420094647.GB1306@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 20, 2011 at 10:46:47AM +0100, Mel Gorman wrote:
> It'd be interesting but for the purposes of this patch I think it
> would be more useful to see the results of some benchmark that is vmap
> intensive. Something directory intensive running on XFS should do the
> job just to confirm no regression, right? A profile might indicate
> how often we end up scanning the full list, finding it dirty and
> calling new_vmap_block but even if something odd showed up there,
> it would be a new patch.

Note that the default mkfs.xfs options will not trigger any vmap
calls at runtime.  You'll need a filesystem with a large directory
block size to trigger heavy vmap usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
