Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 011136B0215
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 10:41:05 -0400 (EDT)
Date: Tue, 22 Jun 2010 22:41:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622144100.GB5477@localhost>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <20100618060901.GA6590@dastard>
 <20100621233628.GL3828@quack.suse.cz>
 <20100622054409.GP7869@dastard>
 <20100621231416.904c50c7.akpm@linux-foundation.org>
 <20100622100924.GQ7869@dastard>
 <20100622131745.GB3338@quack.suse.cz>
 <20100622135234.GA11561@localhost>
 <20100622143124.GA15235@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622143124.GA15235@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "peterz@infradead.org" <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 10:31:24PM +0800, Christoph Hellwig wrote:
> On Tue, Jun 22, 2010 at 09:52:34PM +0800, Wu Fengguang wrote:
> > 2) most writeback will be submitted by one per-bdi-flusher, so no worry
> >    of cache bouncing (this also means the per CPU counter error is
> >    normally bounded by the batch size)
> 
> What counter are we talking about exactly?  Once balanance_dirty_pages

bdi_stat(bdi, BDI_WRITTEN) introduced in this patch.

> stops submitting I/O the per-bdi flusher thread will in fact be
> the only thing submitting writeback, unless you count direct invocations
> of writeback_single_inode. 

Right. 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
