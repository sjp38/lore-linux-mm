Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 380976B003B
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:25:13 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id k14so743169wgh.23
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:25:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i8si18412849wje.55.2014.02.25.10.25.11
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 10:25:11 -0800 (PST)
Message-ID: <530CDFE0.10800@redhat.com>
Date: Tue, 25 Feb 2014 13:24:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: per-thread vma caching
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/25/2014 01:16 PM, Davidlohr Bueso wrote:

> The proposed approach is to keep the current cache and adding a small, per
> thread, LRU cache. By keeping the mm->mmap_cache, 

This bit of the changelog may want updating :)

> Changes from v1 (https://lkml.org/lkml/2014/2/21/8): 
> - Removed the per-mm cache for CONFIG_MMU, only having the 
>   per thread approach.

The patch looks good.

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
