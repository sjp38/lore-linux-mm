Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 4E9906B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 23:53:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 55C693EE0B6
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:53:08 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B7B945DEB4
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:53:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 213C945DEB2
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:53:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D0BE01DB803C
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:53:07 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 692D5E08002
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 12:53:07 +0900 (JST)
Message-ID: <4FEE77A4.2000302@jp.fujitsu.com>
Date: Sat, 30 Jun 2012 12:51:00 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where
 it left
References: <20120628135520.0c48b066@annuminas.surriel.com>
In-Reply-To: <20120628135520.0c48b066@annuminas.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, jaschut@sandia.gov, minchan@kernel.org

(2012/06/29 2:55), Rik van Riel wrote:
> Order > 0 compaction stops when enough free pages of the correct
> page order have been coalesced. When doing subsequent higher order
> allocations, it is possible for compaction to be invoked many times.
>
> However, the compaction code always starts out looking for things to
> compact at the start of the zone, and for free pages to compact things
> to at the end of the zone.
>
> This can cause quadratic behaviour, with isolate_freepages starting
> at the end of the zone each time, even though previous invocations
> of the compaction code already filled up all free memory on that end
> of the zone.
>
> This can cause isolate_freepages to take enormous amounts of CPU
> with certain workloads on larger memory systems.
>
> The obvious solution is to have isolate_freepages remember where
> it left off last time, and continue at that point the next time
> it gets invoked for an order > 0 compaction. This could cause
> compaction to fail if cc->free_pfn and cc->migrate_pfn are close
> together initially, in that case we restart from the end of the
> zone and try once more.
>
> Forced full (order == -1) compactions are left alone.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Reported-by: Jim Schutt <jaschut@sandia.gov>
> Signed-off-by: Rik van Riel <riel@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
