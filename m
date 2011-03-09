Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D4CA58D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 12:01:07 -0500 (EST)
Date: Wed, 9 Mar 2011 18:00:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] remove compaction from kswapd
Message-ID: <20110309170041.GF2141@random.random>
References: <20110228222138.GP22700@random.random>
 <AANLkTingkWo6dx=0sGdmz9qNp+_TrQnKXnmASwD8LhV4@mail.gmail.com>
 <20110301223954.GI19057@random.random>
 <AANLkTim7tcPTxG9hyFiSnQ7rqfMdoUhL1wrmqNAXAvEK@mail.gmail.com>
 <20110301164143.e44e5699.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301164143.e44e5699.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

On Tue, Mar 01, 2011 at 04:41:43PM -0800, Andrew Morton wrote:
> help a lot!  It would be better to have some good, solid quantitative
> justification for what is really an emergency patch.  

I figured it should be ok to post at least differential results:

Req/Achieved   Response Time (msec/Op)
NFS Ops      
per sec.    DIFF
-------------------------------------
 2000       0.0
 4000       0.1
 6000       0.0
 8000       0.2
10000       0.8
12000       3.2
14000       5.1
16000       4.0
18000       4.4
20000       4.5
22000       4.6
24000       3.6 (server resources nearly exhausted)
26000       0.8
28000       0.1
30000       0.0

That would be the difference between upstream and all patches posted
so far. Including only Mel's patch in Message-ID:
<20110302142542.GE14162@csn.ul.ie> is enough to achieve this (no need
of the lowlatency fixes as that patch makes compaction stop running in
a loop). If we only apply the other lowlatency fixes but not Me's
patch in the message-id above, the response time difference is smaller
but not as low as with the patch 20110302142542.GE14162@csn.ul.ie.

The numbers are very reproducible so it's no measurement error even if
it's only a few msec diff. Throughput isn't significantly affected the
real thing affected is latency (and as said just applying the
lowlatency fixes of compaction isn't enough to fix latency and
compaction still shows at top of profiling).

It's not measured on the raw upstream kernel but the compaction code
is mostly identical.

Hope this helps and I'd like to see Mel's patch included.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
