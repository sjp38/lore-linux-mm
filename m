Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B0143600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 10:28:19 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8C65482C7A3
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 11:11:44 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id G+KQYDT+qcx4 for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 11:11:44 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 79E2A82C7D4
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 11:11:32 -0400 (EDT)
Date: Thu, 1 Oct 2009 11:03:16 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a
 kmem_cache_cpu
In-Reply-To: <20091001150346.GD21906@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0910011101390.3911@gentwo.org>
References: <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com> <20090922135453.GF25965@csn.ul.ie> <84144f020909221154x820b287r2996480225692fad@mail.gmail.com> <20090922185608.GH25965@csn.ul.ie> <20090930144117.GA17906@csn.ul.ie>
 <alpine.DEB.1.10.0909301053550.9450@gentwo.org> <20090930220541.GA31530@csn.ul.ie> <alpine.DEB.1.10.0909301941570.11850@gentwo.org> <20091001104046.GA21906@csn.ul.ie> <alpine.DEB.1.10.0910011028380.3911@gentwo.org> <20091001150346.GD21906@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Mel Gorman wrote:

> True, it might have been improved more if SLUB knew what local hugepage it
> resided within as the kernel portion of the address space is backed by huge
> TLB entries. Note that SLQB could have an advantage here early in boot as
> the page allocator will tend to give it back pages within a single huge TLB
> entry. It loses the advantage when the system has been running for a very long
> time but it might be enough to skew benchmark results on cold-booted systems.

The page allocator serves pages aligned to huge page boundaries as far as
I can remember. You can actually use huge pages in slub if you set the max
order to 9. So a page obtained from the page allocator is always aligned
properly.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
