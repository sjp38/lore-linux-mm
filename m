Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEA0C9000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 02:07:22 -0400 (EDT)
Date: Wed, 27 Apr 2011 02:06:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] split inode_wb_list_lock into bdi_writeback.list_lock
Message-ID: <20110427060642.GA11727@infradead.org>
References: <20110426144218.GA14862@localhost>
 <20110426144209.06317674.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110426144209.06317674.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 26, 2011 at 02:42:09PM -0700, Andrew Morton wrote:
> Has this patch been well tested under lockdep?

Yes. There's only two places locking two bdis, and both use the
bdi_lock_two helper which imposes an ordering, and tells lockdep about
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
