Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3A16B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 17:14:14 -0400 (EDT)
Date: Thu, 29 Jul 2010 22:13:10 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Message-ID: <20100729211310.GA28330@n2100.arm.linux.org.uk>
References: <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop> <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home> <20100729183320.GH18923@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1007291438290.21024@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007291438290.21024@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 02:55:53PM -0500, Christoph Lameter wrote:
> On Thu, 29 Jul 2010, Russell King - ARM Linux wrote:
> 
> > And no, setting the sparse section size to 512kB doesn't work - memory is
> > offset by 256MB already, so you need a sparsemem section array of 1024
> > entries just to cover that - with the full 256MB populated, that's 512
> > unused entries followed by 512 used entries.  That too is going to waste
> > memory like nobodies business.
> 
> SPARSEMEM EXTREME does not handle that?
> 
> Some ARMs seem to have MMUs. If so then use SPARSEMEM_VMEMMAP. You can map
> 4k pages for the mmap through a page table. Redirect unused 4k blocks to
> the NULL page.

We're going over old ground which has already been covered in this very
thread.  I've no compunction to repeat the arguments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
