Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B53316B02AB
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 22:50:13 -0400 (EDT)
Date: Sun, 11 Jul 2010 10:50:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/6] writeback cleanups and trivial fixes
Message-ID: <20100711025008.GA24093@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711024404.GA6805@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100711024404.GA6805@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

[add cc to Jens]

On Sun, Jul 11, 2010 at 10:44:04AM +0800, Christoph Hellwig wrote:
> On Sun, Jul 11, 2010 at 10:06:56AM +0800, Wu Fengguang wrote:
> > Andrew,
> > 
> > Here are some writeback cleanups to avoid unnecessary calculation overheads,
> > and relative simple bug fixes.
> > 
> > The patch applies to latest linux-next tree. The mmotm tree will need rebase
> > to include commit 32422c79 (writeback: Add tracing to balance_dirty_pages)
> > in order to avoid merge conflicts.
> 
> Maybe it's a better idea to get them in through Jens' tree?  At least he
> has handled all my flusher thread patches, and I have another big series
> in preparation which might cause some interesting conflicts if not
> merged through the same tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
