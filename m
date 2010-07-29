Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C4BD6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 13:30:29 -0400 (EDT)
Date: Thu, 29 Jul 2010 12:30:23 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <20100729170313.GB16420@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1007291222410.17734@router.home>
References: <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com> <alpine.DEB.2.00.1007270929290.28648@router.home> <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com> <alpine.DEB.2.00.1007281005440.21717@router.home>
 <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home> <20100728225756.GA6108@barrios-desktop> <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home>
 <20100729170313.GB16420@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jul 2010, Minchan Kim wrote:

> But Russell doesn't want it.
> Please, look at the discussion.
>
> http://www.spinics.net/lists/arm-kernel/msg93026.html
>
> In fact, we didn't determine the approache at that time.
> But I think we can't give up ARM's usecase although sparse model
> dosn't be desinged to the such granularity. and I think this approach

The sparse model goes down to page size memmap granularity. The problem
that you may have is with aligning the maximum allocation unit of the
page allocator with the section size of sparsemem. If you reduce your
maximum allocation units then you can get more granularity.

> can solve ARM's FLATMEM's pfn_valid problem which is doing binar search.

OMG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
