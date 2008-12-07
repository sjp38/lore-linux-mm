Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB78Mope007077
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 7 Dec 2008 17:22:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E21145DE52
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 17:22:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 20E6045DD72
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 17:22:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF76D1DB8040
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 17:22:49 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A53401DB803B
	for <linux-mm@kvack.org>; Sun,  7 Dec 2008 17:22:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into pcp
In-Reply-To: <20081205154006.GA19366@csn.ul.ie>
References: <Pine.LNX.4.64.0811071244330.5387@quilx.com> <20081205154006.GA19366@csn.ul.ie>
Message-Id: <20081207172115.53E1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  7 Dec 2008 17:22:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> ====== CUT HERE ======
> From: Mel Gorman <mel@csn.ul.ie>
> Subject: [RFC] Split per-cpu list into one-list-per-migrate-type
> 
> Currently the per-cpu page allocator searches the PCP list for pages of the
> correct migrate-type to reduce the possibility of pages being inappropriate
> placed from a fragmentation perspective. This search is potentially expensive
> in a fast-path and undesirable. Splitting the per-cpu list into multiple lists
> increases the size of a per-cpu structure and this was potentially a major
> problem at the time the search was introduced. These problem has been
> mitigated as now only the necessary number of structures is allocated for the
> running system.
> 
> This patch replaces a list search in the per-cpu allocator with one list
> per migrate type that should be in use by the per-cpu allocator - namely
> unmovable, reclaimable and movable.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Great.

this patch works well on my box too.
and my review didn't find any bug.

very thanks.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
