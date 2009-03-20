Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5BD7C6B0085
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:29:47 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 667F982C9A2
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:10:25 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AYu8XyuWqUpt for <linux-mm@kvack.org>;
	Fri, 20 Mar 2009 11:10:20 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BD64A82C834
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:10:20 -0400 (EDT)
Date: Fri, 20 Mar 2009 11:00:42 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00/25] Cleanup and optimise the page allocator V5
In-Reply-To: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903201059240.3740@qirst.com>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Mar 2009, Mel Gorman wrote:

> The lock contention on some machines goes up for the the zone->lru_lock
> and zone->lock locks which can regress some workloads even though others on
> the same machine still go faster. For netperf, a lock called slock-AF_INET
> seemed very important although I didn't look too closely other than noting
> contention went up. The zone->lock gets hammered a lot by high order allocs
> and frees coming from SLUB which are not covered by the PCP allocator in
> this patchset. zone->lru_lock goes up is less clear but as it's page cache
> releases but overall contention may be up because CPUs are spending less
> time with interrupts disabled and more time trying to do real work but
> contending on the locks.

We can tune SLUB to buffer more pages if the lru lock becomes too hot.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
