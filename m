Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BB5286B00F4
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 05:24:07 -0400 (EDT)
Date: Mon, 13 Sep 2010 11:23:55 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/17] writeback: remove the internal 5% low bound on
 dirty_ratio
Message-ID: <20100913092355.GA20954@cmpxchg.org>
References: <20100912154945.758129106@intel.com>
 <20100912155202.733389420@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100912155202.733389420@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 12, 2010 at 11:49:46PM +0800, Wu Fengguang wrote:
> The dirty_ratio was siliently limited in global_dirty_limits() to >= 5%.
> This is not a user expected behavior. And it's inconsistent with
> calc_period_shift(), which uses the plain vm_dirty_ratio value.
> 
> Let's rip the arbitrary internal bound. It may impact some very weird
> user space applications. However we are going to dynamicly sizing the
> dirty limits anyway, which may well break such applications, too.
> 
> At the same time, fix balance_dirty_pages() to work with the
> dirty_thresh=0 case. This allows applications to proceed when
> dirty+writeback pages are all cleaned.
> 
> And ">" fits with the name "exceeded" better than ">=" does. Neil
> think it is an aesthetic improvement as well as a functional one :)
> 
> CC: Jan Kara <jack@suse.cz>
> Proposed-by: Con Kolivas <kernel@kolivas.org>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Neil Brown <neilb@suse.de>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
