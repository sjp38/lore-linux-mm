Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6ABEE6B02A5
	for <linux-mm@kvack.org>; Sun,  8 Aug 2010 02:42:45 -0400 (EDT)
Date: Sun, 8 Aug 2010 15:42:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
In-Reply-To: <20100805150232.GE25688@csn.ul.ie>
References: <20100805151125.31BA.A69D9226@jp.fujitsu.com> <20100805150232.GE25688@csn.ul.ie>
Message-Id: <20100808153750.5AC6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> This patch (as well as most of the series) will reject against current mmotm
> because of other reclaim-related patches already in there. The resolutions
> are not too hard but bear it in mind.

I was working on latest published mmotm. but yes, current akpm private mmotm
incluse your reclaim related change.

That said, I need to rework them later.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
