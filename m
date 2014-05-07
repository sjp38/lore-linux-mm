Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2BE6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 05:39:40 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so516037eek.41
        for <linux-mm@kvack.org>; Wed, 07 May 2014 02:39:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si15818689eeu.19.2014.05.07.02.39.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 02:39:39 -0700 (PDT)
Date: Wed, 7 May 2014 10:39:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v3 5/6] mm, thp: avoid excessive compaction latency
 during fault
Message-ID: <20140507093935.GE23991@suse.de>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 06, 2014 at 07:22:50PM -0700, David Rientjes wrote:
> Synchronous memory compaction can be very expensive: it can iterate an enormous 
> amount of memory without aborting, constantly rescheduling, waiting on page
> locks and lru_lock, etc, if a pageblock cannot be defragmented.
> 
> Unfortunately, it's too expensive for transparent hugepage page faults and 
> it's much better to simply fallback to pages.  On 128GB machines, we find that 
> synchronous memory compaction can take O(seconds) for a single thp fault.
> 
> Now that async compaction remembers where it left off without strictly relying
> on sync compaction, this makes thp allocations best-effort without causing
> egregious latency during fault.  We still need to retry async compaction after
> reclaim, but this won't stall for seconds.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
