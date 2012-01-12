Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 4B9526B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:26:46 -0500 (EST)
Date: Thu, 12 Jan 2012 19:26:44 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
Message-ID: <20120112182644.GE11715@one.firstfloor.org>
References: <1326380820.2442.186.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326380820.2442.186.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Andi Kleen <andi@firstfloor.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 12, 2012 at 04:07:00PM +0100, Peter Zijlstra wrote:
> Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
> to be compared to either a total of interleave allocations or to a miss
> count, remove it.

Nack!

This would break the numactl testsuite.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
