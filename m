Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2D58D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 08:54:14 -0500 (EST)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1PmRXe-00036W-9z
	for linux-mm@kvack.org; Mon, 07 Feb 2011 13:54:10 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PmRXd-0008Km-1P
	for linux-mm@kvack.org; Mon, 07 Feb 2011 13:54:09 +0000
Subject: Re: [PATCH 01/25] tile: Fix __pte_free_tlb
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4D4C63ED.6060104@tilera.com>
References: <20110125173111.720927511@chello.nl>
	 <20110125174907.220115681@chello.nl>  <4D4C63ED.6060104@tilera.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Feb 2011 14:55:11 +0100
Message-ID: <1297086911.13327.17.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Fri, 2011-02-04 at 15:39 -0500, Chris Metcalf wrote:
> On 1/25/2011 12:31 PM, Peter Zijlstra wrote:
> > Tile's __pte_free_tlb() implementation makes assumptions about the
> > generic mmu_gather implementation, cure this ;-)
> 
> I assume you will take this patch into your tree?  If so:
> 
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>

Feel free to take it yourself, this series might take a while to land..

> > [ Chris, from a quick look L2_USER_PGTABLE_PAGES is something like:
> >   1 << (24 - 16 + 3), which looks awefully large for an on-stack
> >   array. ]
> 
> Yes, the pte_pages[] array in this routine is 2KB currently.  Currently we
> ship with 64KB pagesize, so the kernel stack has plenty of room.  I do like
> that your patch removes this buffer, however, since we're currently looking
> into (re-)supporting 4KB pages, which would totally blow the kernel stack
> in this routine.

Ah, ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
