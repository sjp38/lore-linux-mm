Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF156B004A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 10:10:31 -0400 (EDT)
Date: Fri, 15 Jul 2011 15:10:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/14] Swap-over-NBD without deadlocking v5
Message-ID: <20110715141021.GZ7529@suse.de>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
 <20110706165146.be7ab61b.akpm@linux-foundation.org>
 <20110707094737.GG15285@suse.de>
 <20110707125831.GA15412@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110707125831.GA15412@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Thu, Jul 07, 2011 at 08:58:31AM -0400, Christoph Hellwig wrote:
> On Thu, Jul 07, 2011 at 10:47:37AM +0100, Mel Gorman wrote:
> > Additional complexity is required for swap-over-NFS but affects the
> > core kernel far less than this series. I do not have a series prepared
> > but from what's in a distro kernel, supporting NFS requires extending
> > address_space_operations for swapfile activation/deactivation with
> > some minor helpers and the bulk of the remaining complexity within
> > NFS itself.
> 
> The biggest addition for swap over NFS is to add proper support for
> a filesystem interface to do I/O on random kernel pages instead of
> the current nasty bmap hack the swapfile code is using. Splitting
> that work from all the required VM infrastructure should make life
> easier for everyone involved and allows merging it independeny as
> both bits have other uses case as well.
> 

The swap-over-nfs patches allows this possibility. There is a swapon
interface added that could be used by the filesystem to ensure the
underlying blocks are allocated and a swap_out/swap_in interface that
takes a struct file, struct page and writeback_control. This would
be an alternative to bmap being used to record the blocks backing
each extent.

Any objection to the swap-over-NBD stuff going ahead to get part of the
complexity out of the way?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
