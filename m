Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BE2766B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 04:36:53 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LMT005SRP9EMY40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Jun 2011 09:36:51 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LMT00DQMP9DM1@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Jun 2011 09:36:50 +0100 (BST)
Date: Wed, 15 Jun 2011 10:36:18 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory Allocator
 added
In-reply-to: <201106142242.25157.arnd@arndb.de>
Message-id: <000901cc2b37$4c21f030$e465d090$%szyprowski@samsung.com>
Content-language: pl
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <20110614170158.GU2419@fooishbar.org>
 <BANLkTi=cJisuP8=_YSg4h-nsjGj3zsM7sg@mail.gmail.com>
 <201106142242.25157.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>, 'Zach Pfeffer' <zach.pfeffer@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Daniel Stone' <daniels@collabora.com>, linux-mm@kvack.org, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-media@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Tuesday, June 14, 2011 10:42 PM Arnd Bergmann wrote:

> On Tuesday 14 June 2011 20:58:25 Zach Pfeffer wrote:
> > I've seen this split bank allocation in Qualcomm and TI SoCs, with
> > Samsung, that makes 3 major SoC vendors (I would be surprised if
> > Nvidia didn't also need to do this) - so I think some configurable
> > method to control allocations is necessarily. The chips can't do
> > decode without it (and by can't do I mean 1080P and higher decode is
> > not functionally useful). Far from special, this would appear to be
> > the default.
> 
> Thanks for the insight, that's a much better argument than 'something
> may need it'. Are those all chips without an IOMMU or do we also
> need to solve the IOMMU case with split bank allocation?
> 
> I think I'd still prefer to see the support for multiple regions split
> out into one of the later patches, especially since that would defer
> the question of how to do the initialization for this case and make
> sure we first get a generic way.
> 
> You've convinced me that we need to solve the problem of allocating
> memory from a specific bank eventually, but separating it from the
> one at hand (contiguous allocation) should help getting the important
> groundwork in at first.
>
> The possible conflict that I still see with per-bank CMA regions are:
> 
> * It completely destroys memory power management in cases where that
>   is based on powering down entire memory banks.

I don't think that per-bank CMA regions destroys memory power management
more than the global CMA pool. Please note that the contiguous buffers
(or in general dma-buffers) right now are unmovable so they don't fit
well into memory power management.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
