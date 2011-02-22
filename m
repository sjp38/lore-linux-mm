Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1BE248D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 11:38:06 -0500 (EST)
Message-ID: <4D63E6EF.3020206@redhat.com>
Date: Tue, 22 Feb 2011 11:40:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random> <20110214022524.GA18198@sli10-conroe.sh.intel.com> <20110222142559.GD15652@csn.ul.ie> <20110222144200.GY13092@random.random> <20110222160449.GF15652@csn.ul.ie>
In-Reply-To: <20110222160449.GF15652@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, alex.shi@intel.com

On 02/22/2011 11:04 AM, Mel Gorman wrote:

> To avoid an excessive number of pages being reclaimed from the larger zones,
> explicitely defines the "balance gap" to be either 1% of the zone or the
> low watermark for the zone, whichever is smaller.  While kswapd will check
> all zones to apply pressure, it'll ignore zones that meets the (high_wmark +
> balance_gap) watermark.
>
> To test this, 80G were copied from a partition and the amount of memory
> being used was recorded. A comparison of a patch and unpatched kernel
> can be seen at
> http://www.csn.ul.ie/~mel/postings/minfree-20110222/memory-usage-hydra.ps
> and shows that kswapd is not reclaiming as much memory with the patch
> applied.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
