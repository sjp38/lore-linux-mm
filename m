Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id C56E16B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:37:19 -0500 (EST)
Date: Thu, 12 Jan 2012 11:37:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
In-Reply-To: <1326380820.2442.186.camel@twins>
Message-ID: <alpine.DEB.2.00.1201121135560.24075@router.home>
References: <1326380820.2442.186.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 12 Jan 2012, Peter Zijlstra wrote:

> Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
> to be compared to either a total of interleave allocations or to a miss
> count, remove it.
>
> Fixing it would be possible, but since we've gone years without these
> statistics I figure we can continue that way.

Never found any use for it.

Acked-by: Christoph Lameter <cl@linux.com>

> This cleans up some of the weird MPOL_INTERLEAVE allocation exceptions.

What others are there? Exceptions in terms of special casing in various
functions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
