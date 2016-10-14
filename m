Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 519DD6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:27:53 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id os4so97413873pac.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 18:27:53 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q10si13074918pgq.196.2016.10.13.18.27.51
        for <linux-mm@kvack.org>;
        Thu, 13 Oct 2016 18:27:52 -0700 (PDT)
Date: Fri, 14 Oct 2016 10:28:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 3/5] mm/page_alloc: stop instantly reusing freed page
Message-ID: <20161014012817.GC4993@js1304-P5Q-DELUXE>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-4-git-send-email-iamjoonsoo.kim@lge.com>
 <44132140-c678-73a2-b747-f04ad0f3d7df@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44132140-c678-73a2-b747-f04ad0f3d7df@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 13, 2016 at 12:59:14PM +0200, Vlastimil Babka wrote:
> On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Allocation/free pattern is usually sequantial. If they are freed to
> >the buddy list, they can be coalesced. However, we first keep these freed
> >pages at the pcp list and try to reuse them until threshold is reached
> >so we don't have enough chance to get a high order freepage. This reusing
> >would provide us some performance advantages since we don't need to
> >get the zone lock and we don't pay the cost to check buddy merging.
> >But, less fragmentation and more high order freepage would compensate
> >this overhead in other ways. First, we would trigger less direct
> >compaction which has high overhead. And, there are usecases that uses
> >high order page to boost their performance.
> >
> >Instantly resuing freed page seems to provide us computational benefit
> >but the other affects more precious things like as I/O performance and
> >memory consumption so I think that it's a good idea to weight
> >later advantage more.
> 
> Again, there's also cache hotness to consider. And whether the
> sequential pattern is still real on a system with higher uptime.
> Should be possible to evaluate with tracepoints?

I answered this in previous e-mail. Anyway, we should evaluate
cache-effect. tracepoint or perf's cache event would show some
evidence. I will do it soon and report again.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
