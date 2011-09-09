Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2FE6B0258
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 09:15:58 -0400 (EDT)
Date: Fri, 9 Sep 2011 14:15:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Message-ID: <20110909131550.GV14369@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
 <20110909130007.GA11810@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110909130007.GA11810@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Sep 09, 2011 at 09:00:08AM -0400, Christoph Hellwig wrote:
> On Fri, Sep 09, 2011 at 12:00:47PM +0100, Mel Gorman wrote:
> > Currently swapfiles are managed entirely by the core VM by using
> > ->bmap to allocate space and write to the blocks directly. This
> > patch adds address_space_operations methods that allow a filesystem
> > to optionally control the swapfile.
> > 
> >   int swap_activate(struct file *);
> >   int swap_deactivate(struct file *);
> >   int swap_writepage(struct file *, struct page *, struct writeback_control *);
> >   int swap_readpage(struct file *, struct page *);
> 
> Just as the last two dozen times this came up:
> 
> NAK
> 
> The right fix is to add a filesystem method to support direct-I/O on
> arbitrary kernel pages, instead of letting the wap abstraction leak into
> the filesystem.

Ok.

I confess I haven't investigated this direction at
all yet.  Is it correct that your previous objection was
http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-10/msg00455.html
and the direct-IO patchset you were thinking of was
http://copilotco.com/mail-archives/linux-kernel.2009/msg87176.html ?

If so, are you suggesting that instead of swap_readpage and
swap_writepage I look into what is required for swap to use ->readpage
method and ->direct_IO aops?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
