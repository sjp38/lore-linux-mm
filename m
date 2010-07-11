Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A6E716B02AB
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 22:44:56 -0400 (EDT)
Date: Sat, 10 Jul 2010 22:44:04 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/6] writeback cleanups and trivial fixes
Message-ID: <20100711024404.GA6805@infradead.org>
References: <20100711020656.340075560@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100711020656.340075560@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 11, 2010 at 10:06:56AM +0800, Wu Fengguang wrote:
> Andrew,
> 
> Here are some writeback cleanups to avoid unnecessary calculation overheads,
> and relative simple bug fixes.
> 
> The patch applies to latest linux-next tree. The mmotm tree will need rebase
> to include commit 32422c79 (writeback: Add tracing to balance_dirty_pages)
> in order to avoid merge conflicts.

Maybe it's a better idea to get them in through Jens' tree?  At least he
has handled all my flusher thread patches, and I have another big series
in preparation which might cause some interesting conflicts if not
merged through the same tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
