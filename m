Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 634796B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 08:57:43 -0400 (EDT)
Date: Thu, 29 Jul 2010 13:57:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: why depends on HUGETLB_PAGE
Message-ID: <20100729125725.GA3571@csn.ul.ie>
References: <D25878F935704D9281E62E0393CAD951@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <D25878F935704D9281E62E0393CAD951@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 10:53:12AM +0900, Iram Shahzad wrote:
> Hi
>
> I have found that memory compaction (CONFIG_COMPACTION)
> is mainlined while looking at 2.6.35-rc5 source code.
> I have a question regarding its dependency on HUGETLB_PAGE.
>
> While trying to use CONFIG_COMPACTION on ARM architecture,
> I found that I cannot enable CONFIG_COMPACTION because
> it depends on CONFIG_HUGETLB_PAGE which is not available
> on ARM.
>
> I disabled the dependency and was able to build it.
> And it looks like working!
>
> My question is: why does it depend on CONFIG_HUGETLB_PAGE?

Because as the Kconfig says "Allows the compaction of memory for the
allocation of huge pages.". Depending on compaction to satisfy other
high-order allocation types is not likely to be a winning strategy.

> Is it wrong to use it on ARM by disabling CONFIG_HUGETLB_PAGE?
>

It depends on why you need compaction. If it's for some device that
requires high-order allocations (particularly if they are atomic), then
it's not likely to work very well in the long term.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
