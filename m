Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 9BD4D6B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 10:28:29 -0400 (EDT)
Date: Fri, 15 Jun 2012 15:28:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] memory hotplug: fix invalid memory access caused by
 stale kswapd pointer
Message-ID: <20120615142820.GC20467@suse.de>
References: <1339645491-5656-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1339645491-5656-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Keping Chen <chenkeping@huawei.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <liuj97@gmail.com>

On Thu, Jun 14, 2012 at 11:44:51AM +0800, Jiang Liu wrote:
> Function kswapd_stop() will be called to destroy the kswapd work thread
> when all memory of a NUMA node has been offlined. But kswapd_stop() only
> terminates the work thread without resetting NODE_DATA(nid)->kswapd to NULL.
> The stale pointer will prevent kswapd_run() from creating a new work thread
> when adding memory to the memory-less NUMA node again. Eventually the stale
> pointer may cause invalid memory access.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Signed-off-by: Jiang Liu <liuj97@gmail.com>
> 

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
