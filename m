Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 297C38D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 11:07:02 -0500 (EST)
Date: Fri, 26 Nov 2010 11:06:19 -0500
From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-ID: <20101126160619.GP22651@bombadil.infradead.org>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
 <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2010 at 09:47:35AM +0100, Mel Gorman wrote:
><snip>
> To ensure that kswapd wakes up, a safe version of zone_watermark_ok()
> is introduced that takes a more accurate reading of NR_FREE_PAGES when
> called from wakeup_kswapd, when deciding whether it is really safe to go
> back to sleep in sleeping_prematurely() and when deciding if a zone is
> really balanced or not in balance_pgdat(). We are still using an expensive
> function but limiting how often it is called.
><snip>
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Hi Mel,

I notice these aren't flagged for stable, should they be? (They fairly
trivially apply and compile on 2.6.36 barring the trace_ points which
changed.) I've got a few bug reports against .36/.37 where kswapd has
been sleeping for 60s+.

I built them some kernels with these patches, but haven't heard back yet
as to whether it fixes things for them.

Thanks for any insight,
	Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
