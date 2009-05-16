Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 612AE6B0087
	for <linux-mm@kvack.org>; Sat, 16 May 2009 09:39:38 -0400 (EDT)
Date: Sat, 16 May 2009 15:39:50 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] vmscan: merge duplicate code in shrink_active_list()
Message-ID: <20090516133950.GA5775@cmpxchg.org>
References: <20090516090005.916779788@intel.com> <20090516090448.535217680@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090516090448.535217680@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 16, 2009 at 05:00:08PM +0800, Wu Fengguang wrote:
> The "move pages to active list" and "move pages to inactive list"
> code blocks are mostly identical and can be served by a function.
> 
> Thanks to Andrew Morton for pointing this out.
> 
> Note that buffer_heads_over_limit check will also be carried out
> for re-activated pages, which is slightly different from pre-2.6.28
> kernels. Also, Rik's "vmscan: evict use-once pages first" patch
> could totally stop scans of active list when memory pressure is low.
> So the net effect could be, the number of buffer heads is now more
> likely to grow large.

I don't think that this could be harmful.  We just preserve the buffer
mappings of what we consider the working set and with low memory
pressure, as you say, this set is not big.

As to stripping of reactivated pages: the only pages we re-activate
for now are those VM_EXEC mapped ones.  Since we don't expect IO from
or to these pages, removing the buffer mappings in case they grow too
large should be okay, I guess.

> CC: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
