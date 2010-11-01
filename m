Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A3BA98D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 03:06:49 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:06:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter threshold when memory is low
In-Reply-To: <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie> <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
Message-Id: <20101101023957.606E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> To ensure that kswapd wakes up, a safe version of zone_watermark_ok()
> is introduced that takes a more accurate reading of NR_FREE_PAGES when
> called from wakeup_kswapd, when deciding whether it is really safe to go
> back to sleep in sleeping_prematurely() and when deciding if a zone is
> really balanced or not in balance_pgdat(). We are still using an expensive
> function but limiting how often it is called.
> 
> When the test case is reproduced, the time spent in the watermark functions
> is reduced. The following report is on the percentage of time spent
> cumulatively spent in the functions zone_nr_free_pages(), zone_watermark_ok(),
> __zone_watermark_ok(), zone_watermark_ok_safe(), zone_page_state_snapshot(),
> zone_page_state().
> 
> vanilla                      11.6615%
> disable-threshold            0.2584%
> 
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Except kamezawa-san pointed piece

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
