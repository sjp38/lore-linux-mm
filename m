Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 977586B0092
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 03:05:09 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB8855WU012061
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Dec 2010 17:05:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C396745DE6D
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:04:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AAED845DE55
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:04:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E4C3E08001
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:04:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 675D91DB8038
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 17:04:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
In-Reply-To: <0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com> <0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
Message-Id: <20101208170504.1750.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  8 Dec 2010 17:04:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

> invalidate_mapping_pages is very big hint to reclaimer.
> It means user doesn't want to use the page any more.
> So in order to prevent working set page eviction, this patch
> move the page into tail of inactive list by PG_reclaim.
> 
> Please, remember that pages in inactive list are working set
> as well as active list. If we don't move pages into inactive list's
> tail, pages near by tail of inactive list can be evicted although
> we have a big clue about useless pages. It's totally bad.
> 
> Now PG_readahead/PG_reclaim is shared.
> fe3cba17 added ClearPageReclaim into clear_page_dirty_for_io for
> preventing fast reclaiming readahead marker page.
> 
> In this series, PG_reclaim is used by invalidated page, too.
> If VM find the page is invalidated and it's dirty, it sets PG_reclaim
> to reclaim asap. Then, when the dirty page will be writeback,
> clear_page_dirty_for_io will clear PG_reclaim unconditionally.
> It disturbs this serie's goal.
> 
> I think it's okay to clear PG_readahead when the page is dirty, not
> writeback time. So this patch moves ClearPageReadahead.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>

Until anyone should data, I will not ack this. This patch increase
VM state, but benefit is doubious.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
