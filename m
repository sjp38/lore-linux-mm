Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3CECF6B0088
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 20:12:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA1CBxB032267
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Dec 2010 10:12:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CBF0845DE73
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:12:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4CCB45DE68
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:12:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6A221DB8038
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:12:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 727E51DB803B
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:12:11 +0900 (JST)
Date: Fri, 10 Dec 2010 10:06:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/6] mm: kswapd: Stop high-order balancing when any
 suitable zone is balanced
Message-Id: <20101210100628.bd890c77.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291893500-12342-2-git-send-email-mel@csn.ul.ie>
References: <1291893500-12342-1-git-send-email-mel@csn.ul.ie>
	<1291893500-12342-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu,  9 Dec 2010 11:18:15 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> When the allocator enters its slow path, kswapd is woken up to balance the
> node. It continues working until all zones within the node are balanced. For
> order-0 allocations, this makes perfect sense but for higher orders it can
> have unintended side-effects. If the zone sizes are imbalanced, kswapd may
> reclaim heavily within a smaller zone discarding an excessive number of
> pages. The user-visible behaviour is that kswapd is awake and reclaiming
> even though plenty of pages are free from a suitable zone.
> 
> This patch alters the "balance" logic for high-order reclaim allowing kswapd
> to stop if any suitable zone becomes balanced to reduce the number of pages
> it reclaims from other zones. kswapd still tries to ensure that order-0
> watermarks for all zones are met before sleeping.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
