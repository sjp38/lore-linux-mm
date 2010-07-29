Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B7DBC6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 15:55:59 -0400 (EDT)
Date: Thu, 29 Jul 2010 14:55:53 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <20100729183320.GH18923@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.00.1007291438290.21024@router.home>
References: <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com> <alpine.DEB.2.00.1007281005440.21717@router.home> <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop>
 <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home>
 <20100729183320.GH18923@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2010, Russell King - ARM Linux wrote:

> And no, setting the sparse section size to 512kB doesn't work - memory is
> offset by 256MB already, so you need a sparsemem section array of 1024
> entries just to cover that - with the full 256MB populated, that's 512
> unused entries followed by 512 used entries.  That too is going to waste
> memory like nobodies business.

SPARSEMEM EXTREME does not handle that?

Some ARMs seem to have MMUs. If so then use SPARSEMEM_VMEMMAP. You can map
4k pages for the mmap through a page table. Redirect unused 4k blocks to
the NULL page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
