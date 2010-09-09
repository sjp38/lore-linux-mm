Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 507936B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 23:23:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o893NCts008295
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Sep 2010 12:23:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CB71045DE57
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:23:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A93D445DE4F
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:23:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8590C1DB803C
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:23:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E0481DB8042
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:23:12 +0900 (JST)
Date: Thu, 9 Sep 2010 12:17:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 08/10] vmscan: isolated_lru_pages() stop neighbour
 search if neighbour cannot be isolated
Message-Id: <20100909121759.d66fb89a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1283770053-18833-9-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
	<1283770053-18833-9-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon,  6 Sep 2010 11:47:31 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> isolate_lru_pages() does not just isolate LRU tail pages, but also isolate
> neighbour pages of the eviction page. The neighbour search does not stop even
> if neighbours cannot be isolated which is excessive as the lumpy reclaim will
> no longer result in a successful higher order allocation. This patch stops
> the PFN neighbour pages if an isolation fails and moves on to the next block.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
