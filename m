Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFC36B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 07:05:02 -0400 (EDT)
Date: Wed, 4 May 2011 07:04:32 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/6] writeback: pass writeback_control down to
 move_expired_inodes()
Message-ID: <20110504110430.GA4646@infradead.org>
References: <20110420080336.441157866@intel.com>
 <20110420080917.759855316@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420080917.759855316@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 20, 2011 at 04:03:37PM +0800, Wu Fengguang wrote:
> No behavior change. This will add debug visibility to the code, for
> example, to dump the wbc contents when kprobing queue_io().

I don't think it's a good idea.  The writeback_control should move
back to just controlling per-inode writeback and not be passed to
more routines dealing with high-level writeback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
