Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 210866B0115
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 08:59:30 -0400 (EDT)
Date: Wed, 13 Oct 2010 13:59:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC][PATCH 1/3] mm, mem-hotplug: recalculate lowmem_reserve
	when memory hotplug occur
Message-ID: <20101013125913.GL30667@csn.ul.ie>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013151723.ADBD.A69D9226@jp.fujitsu.com> <20101013152713.ADC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101013152713.ADC0.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 03:27:12PM +0900, KOSAKI Motohiro wrote:
> Currently, memory hotplu call setup_per_zone_wmarks() and
> calculate_zone_inactive_ratio(), but don't call setup_per_zone_lowmem_reserve.
> 
> It mean number of reserved pages aren't updated even if memory hot plug
> occur. This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Ok, I see the logic although the changelog needs a better description as
to why this matters and what the consequences are. It appears unrelated
to Shaohua's problem for example. Otherwise the patch looks reasonable

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
