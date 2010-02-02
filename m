Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 429BB6B0071
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 08:23:20 -0500 (EST)
Date: Tue, 2 Feb 2010 07:23:15 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202132315.GN6653@sgi.com>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202125943.GH4135@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 01:59:43PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 02, 2010 at 03:09:47AM -0500, Christoph Hellwig wrote:
> > On Mon, Feb 01, 2010 at 10:01:45PM -0600, Robin Holt wrote:
> > > XPMEM would like to utilize mmu_notifiers to track page table entry
> > > changes of the segment and keep the attachment page table/tlb information
> > > consistent.
> > 
> > Given that SGI just pushes XPMEM direclty into the distributions instead
> > of adding it upstream I don't really see the relevance of these patches.
> 
> That will then prevent upstream modules to build against those
> kernels. Not an huge issue, for a distro that's an ok compromise. My
> real issue with mainline is that while XPMEM is ok to break and
> corrupt memory if people uses XPMEM on top of shared mappings (instead
> of anonymous ones) by making a two liner change to the userland app
> opening xpmem device, but when next mmu notifier user comes and ask
> for full scheduling across shared mapping too as it needs security and
> not-trusted user can open /dev/xpmem (or whatever that device is
> located), we'll have to undo this work and fix it the real way (with
> config option MMU_NOTIFIER_SLEEPABLE=y). But if distro have to support
> XPMEM in default kernels, this hack is better because it won't
> slowdown the locking even if it leaves holes and corrupts memory when
> XPMEM can be opened by luser. It really depends if the user having

Where is it leaving holes and corrupting memory?

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
