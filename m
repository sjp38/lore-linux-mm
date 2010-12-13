Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CEF216B0088
	for <linux-mm@kvack.org>; Sun, 12 Dec 2010 21:08:48 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBD28iHc011311
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Dec 2010 11:08:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 673FE45DE5B
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:08:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ACF945DE55
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:08:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3770AE08002
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:08:44 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E458F1DB803C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 11:08:43 +0900 (JST)
Date: Mon, 13 Dec 2010 11:03:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: kswapd: Keep kswapd awake for high-order
 allocations until a percentage of the node is balanced
Message-Id: <20101213110301.655194ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291995985-5913-3-git-send-email-mel@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
	<1291995985-5913-3-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2010 15:46:21 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> When reclaiming for high-orders, kswapd is responsible for balancing a
> node but it should not reclaim excessively. It avoids excessive reclaim by
> considering if any zone in a node is balanced then the node is balanced. In
> the cases where there are imbalanced zone sizes (e.g. ZONE_DMA with both
> ZONE_DMA32 and ZONE_NORMAL), kswapd can go to sleep prematurely as just
> one small zone was balanced.
> 
> This alters the sleep logic of kswapd slightly. It counts the number of pages
> that make up the balanced zones. If the total number of balanced pages is
> more than a quarter of the zone, kswapd will go back to sleep. This should
> keep a node balanced without reclaiming an excessive number of pages.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
