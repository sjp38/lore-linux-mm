Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2F56B0095
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:01:28 -0400 (EDT)
Date: Thu, 16 Jul 2009 17:59:54 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: count only reclaimable lru pages v2
Message-ID: <20090716155954.GA1883@cmpxchg.org>
References: <20090716133454.GA20550@localhost> <alpine.DEB.1.10.0907160959260.32382@gentwo.org> <20090716142533.GA27165@localhost> <1247754491.6586.23.camel@laptop> <alpine.DEB.1.10.0907161037590.7930@gentwo.org> <4A5F3C70.7010001@redhat.com> <20090716150901.GA31204@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090716150901.GA31204@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 11:09:01PM +0800, Wu Fengguang wrote:

> mm: count only reclaimable lru pages 
> 
> global_lru_pages() / zone_lru_pages() can be used in two ways:
> - to estimate max reclaimable pages in determine_dirtyable_memory()  
> - to calculate the slab scan ratio
> 
> When swap is full or not present, the anon lru lists are not reclaimable
> and also won't be scanned. So the anon pages shall not be counted in both
> usage scenarios. Also rename to _reclaimable_pages: now they are counting
> the possibly reclaimable lru pages.
> 
> It can greatly (and correctly) increase the slab scan rate under high memory
> pressure (when most file pages have been reclaimed and swap is full/absent),
> thus reduce false OOM kills.
> 
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
