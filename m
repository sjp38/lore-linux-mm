Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B3B66B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 04:12:15 -0400 (EDT)
Date: Thu, 30 Apr 2009 10:10:29 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v3)
Message-ID: <20090430081029.GA23231@cmpxchg.org>
References: <20090428044426.GA5035@eskimo.com> <20090428192907.556f3a34@bree.surriel.com> <1240987349.4512.18.camel@laptop> <20090429114708.66114c03@cuia.bos.redhat.com> <2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com> <20090429131436.640f09ab@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090429131436.640f09ab@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 01:14:36PM -0400, Rik van Riel wrote:
> When the file LRU lists are dominated by streaming IO pages,
> evict those pages first, before considering evicting other
> pages.
> 
> This should be safe from deadlocks or performance problems
> because only three things can happen to an inactive file page:
> 1) referenced twice and promoted to the active list
> 2) evicted by the pageout code
> 3) under IO, after which it will get evicted or promoted
> 
> The pages freed in this way can either be reused for streaming
> IO, or allocated for something else. If the pages are used for
> streaming IO, this pageout pattern continues. Otherwise, we will
> fall back to the normal pageout pattern.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

Although Elladan didn't test this exact patch, he reported on v2 that
the general idea of scanning active files only when they exceed the
inactive set works.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
