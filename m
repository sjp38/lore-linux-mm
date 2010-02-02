Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB9F6B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 03:09:57 -0500 (EST)
Date: Tue, 2 Feb 2010 03:09:47 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
	sleep.
Message-ID: <20100202080947.GA28736@infradead.org>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202040145.555474000@alcatraz.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 01, 2010 at 10:01:45PM -0600, Robin Holt wrote:
> XPMEM would like to utilize mmu_notifiers to track page table entry
> changes of the segment and keep the attachment page table/tlb information
> consistent.

Given that SGI just pushes XPMEM direclty into the distributions instead
of adding it upstream I don't really see the relevance of these patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
