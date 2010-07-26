Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA8C6006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 07:12:24 -0400 (EDT)
Date: Mon, 26 Jul 2010 12:12:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/4] memcg: add mm_vmscan_memcg_isolate tracepoint
Message-ID: <20100726111206.GQ5300@csn.ul.ie>
References: <20100726120107.2EEE.A69D9226@jp.fujitsu.com> <20100726120519.2EFA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100726120519.2EFA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 12:06:05PM +0900, KOSAKI Motohiro wrote:
> Memcg also need to trace page isolation information as global reclaim.
> This patch does it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
