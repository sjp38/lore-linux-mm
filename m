Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CBD37900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:16:32 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LN700L1X0U7RZ@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Jun 2011 14:15:44 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN700NNI0U63Z@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Jun 2011 14:15:43 +0100 (BST)
Date: Wed, 22 Jun 2011 15:15:35 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory	Allocator
 added
In-reply-to: <201106221442.20848.arnd@arndb.de>
Message-id: <003701cc30de$7a159710$6e40c530$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <201106150937.18524.arnd@arndb.de> <201106220903.31065.hverkuil@xs4all.nl>
 <201106221442.20848.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>, 'Hans Verkuil' <hverkuil@xs4all.nl>
Cc: 'Daniel Walker' <dwalker@codeaurora.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hello,

On Wednesday, June 22, 2011 2:42 PM Arnd Bergmann wrote:

> On Wednesday 22 June 2011, Hans Verkuil wrote:
> > > How about a Kconfig option that defines the percentage of memory
> > > to set aside for contiguous allocations?
> >
> > I would actually like to see a cma_size kernel option of some sort. This
> would
> > be for the global CMA pool only as I don't think we should try to do
> anything
> > more complicated here.
> 
> A command line is probably good to override the compile-time default, yes.
> 
> We could also go further and add a runtime sysctl mechanism like the one
> for hugepages, where you can grow the pool at run time as long as there is
> enough free contiguous memory (e.g. from init scripts), or shrink it later
> if you want to allow larger nonmovable allocations.

Sounds really good, but it might be really hard to implemnt, at least for
CMA, because it needs to tweak parameters of memory management internal 
structures very early, when buddy allocator has not been activated yet.

> My feeling is that we need to find a way to integrate the global settings
> for four kinds of allocations:
> 
> * nonmovable kernel pages
> * hugetlb pages
> * CMA
> * memory hotplug
> 
> These essentially fight over the same memory (though things are slightly
> different with dynamic hugepages), and they all face the same basic problem
> of getting as much for themselves without starving the other three.

I'm not sure we can solve all such issues in the first version. Maybe we should
first have each of the above fully working in mainline separately and then
start the integration works.

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
