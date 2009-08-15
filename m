Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F40A46B004D
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 15:57:36 -0400 (EDT)
Date: Sat, 15 Aug 2009 15:57:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch] fs: turn iprune_mutex into rwsem
Message-ID: <20090815195742.GA14842@infradead.org>
References: <20090814152504.GA19195@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090814152504.GA19195@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 05:25:05PM +0200, Nick Piggin wrote:
> Now I think the main problem is having the filesystem block (and do IO
> in inode reclaim. The problem is that this doesn't get accounted well
> and penalizes a random allocator with a big latency spike caused by
> work generated from elsewhere.
> 
> I think the best idea would be to avoid this. By design if possible,
> or by deferring the hard work to an asynchronous context. If the latter,
> then the fs would probably want to throttle creation of new work with
> queue size of the deferred work, but let's not get into those details.

I don't really see a good way to avoid this.  For any filesystem that
does some sort of preallocations we need to drop them in ->clear_inode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
