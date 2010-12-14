Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C83A6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 17:34:38 -0500 (EST)
Date: Tue, 14 Dec 2010 14:33:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/6] mm: kswapd: Stop high-order balancing when any
 suitable zone is balanced
Message-Id: <20101214143306.485f2c7c.akpm@linux-foundation.org>
In-Reply-To: <1291995985-5913-2-git-send-email-mel@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
	<1291995985-5913-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010 15:46:20 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> When the allocator enters its slow path, kswapd is woken up to balance the
> node. It continues working until all zones within the node are balanced. For
> order-0 allocations, this makes perfect sense but for higher orders it can
> have unintended side-effects. If the zone sizes are imbalanced, kswapd may
> reclaim heavily within a smaller zone discarding an excessive number of
> pages.

Why was it doing this?  

> The user-visible behaviour is that kswapd is awake and reclaiming
> even though plenty of pages are free from a suitable zone.

Suitable for what?  I assume you refer to a future allocation which can
be satisfied from more than one of the zones?

But what if that allocation wanted to allocate a high-order page from
a zone which we just abandoned?

> This patch alters the "balance" logic for high-order reclaim allowing kswapd
> to stop if any suitable zone becomes balanced to reduce the number of pages

again, suitable for what?

> it reclaims from other zones. kswapd still tries to ensure that order-0
> watermarks for all zones are met before sleeping.

Handling order-0 pages differently from higher-order pages sounds weird
and wrong.

I don't think I understand this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
