Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F9D96B007D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 08:35:54 -0500 (EST)
Date: Tue, 2 Feb 2010 07:35:50 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202133550.GP6653@sgi.com>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202080947.GA28736@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 03:09:47AM -0500, Christoph Hellwig wrote:
> On Mon, Feb 01, 2010 at 10:01:45PM -0600, Robin Holt wrote:
> > XPMEM would like to utilize mmu_notifiers to track page table entry
> > changes of the segment and keep the attachment page table/tlb information
> > consistent.
> 
> Given that SGI just pushes XPMEM direclty into the distributions instead
> of adding it upstream I don't really see the relevance of these patches.

XPMEM has in the past and will again be pushed to the community.  We are
not pushing it to the distros.  We have asked them to take very minor
patches which have all, with the exception of one, been accepted upstream.
The one which has not been accepted upstream has not even been pushed and
that is only turning on MMU_NOTIFIER when CONFIG_IA64 && CONFIG_SGI_XP
are set.

We build xpmem as a GPL out of tree kernel module and library.  The
sources are shipped with the SGI ProPack product CD.  Any customer could
rebuild the kernel module with a simple rpmbuild --rebuild xpmem*.src.rpm
if they wanted.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
