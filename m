Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2EFFD8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 09:55:20 -0500 (EST)
Date: Tue, 22 Feb 2011 15:54:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110222145450.GA13092@random.random>
References: <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110203025808.GJ5843@random.random>
 <20110214022524.GA18198@sli10-conroe.sh.intel.com>
 <20110222142559.GD15652@csn.ul.ie>
 <20110222144200.GY13092@random.random>
 <20110222145030.GE15652@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222145030.GE15652@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, Rik van Riel <riel@redhat.com>, alex.shi@intel.com

On Tue, Feb 22, 2011 at 02:50:31PM +0000, Mel Gorman wrote:
> For workloads that cause a lot of fragmentation - yes. Simplistically with 1,
> the trace event mm_page_alloc_extfrag will trigger more frequently and
> it's more likely to be severe. The problem is that if it's not "* 2",
> there is a very low probability that there will pages free in a suitable
> pageblock and "mixing" occurs. It can take a very long time for
> allocation success rates to go down but it happens eventually.

Ok I see. Thanks for the clarification.

So I think the other two spots I quoted in prev email are the only two
bits we can adjust if booting madvise doesn't fix it completely (in
addition to the *8 removal in kswapd, but that only affects ~4G
systems, that are however very common this is an old bug that just got
better exposed with an higher min_free_kbytes default).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
