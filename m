Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC26A6B01A7
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 09:00:17 -0400 (EDT)
Date: Fri, 9 Sep 2011 09:00:08 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Message-ID: <20110909130007.GA11810@infradead.org>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315566054-17209-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Sep 09, 2011 at 12:00:47PM +0100, Mel Gorman wrote:
> Currently swapfiles are managed entirely by the core VM by using
> ->bmap to allocate space and write to the blocks directly. This
> patch adds address_space_operations methods that allow a filesystem
> to optionally control the swapfile.
> 
>   int swap_activate(struct file *);
>   int swap_deactivate(struct file *);
>   int swap_writepage(struct file *, struct page *, struct writeback_control *);
>   int swap_readpage(struct file *, struct page *);

Just as the last two dozen times this came up:

NAK

The right fix is to add a filesystem method to support direct-I/O on
arbitrary kernel pages, instead of letting the wap abstraction leak into
the filesystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
