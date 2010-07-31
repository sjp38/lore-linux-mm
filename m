Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 145E96B02B1
	for <linux-mm@kvack.org>; Sat, 31 Jul 2010 06:40:10 -0400 (EDT)
Date: Sat, 31 Jul 2010 11:38:49 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Message-ID: <20100731103849.GH23886@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop> <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home> <20100729183320.GH18923@n2100.arm.linux.org.uk> <1280436919.16922.11246.camel@nimitz> <AANLkTi=DpH=vmUK84KhvOMgP=KL+YxXD0UhiJE+VRJyg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=DpH=vmUK84KhvOMgP=KL+YxXD0UhiJE+VRJyg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 06:32:04PM +0900, Minchan Kim wrote:
> On Fri, Jul 30, 2010 at 5:55 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > If you free up parts of the mem_map[] array, how does the buddy
> > allocator still work?  I thought we required at 'struct page's to be
> > contiguous and present for at least 2^MAX_ORDER-1 pages in one go.

(Dave, I don't seem to have your mail to reply to.)

What you say is correct, and memory banks as a rule of thumb tend to be
powers of two.

We do have the ability to change MAX_ORDER (which we need to do for some
platforms where there's only 1MB of DMA-able memory.)

However, in the case of two 512KB banks, the buddy allocator won't try
to satisfy a 1MB request as it'll only have two separate 2x512K free
'pages' to deal with, and 0x1M free 'pages'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
