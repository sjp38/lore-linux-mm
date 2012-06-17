Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id C2EC56B004D
	for <linux-mm@kvack.org>; Sat, 16 Jun 2012 22:20:12 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so8354203pbb.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2012 19:20:12 -0700 (PDT)
Date: Sat, 16 Jun 2012 19:20:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memory hotplug: fix invalid memory access caused by
 stale kswapd pointer
In-Reply-To: <1339645491-5656-1-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.00.1206161919580.797@chino.kir.corp.google.com>
References: <1339645491-5656-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Keping Chen <chenkeping@huawei.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <liuj97@gmail.com>

On Thu, 14 Jun 2012, Jiang Liu wrote:

> Function kswapd_stop() will be called to destroy the kswapd work thread
> when all memory of a NUMA node has been offlined. But kswapd_stop() only
> terminates the work thread without resetting NODE_DATA(nid)->kswapd to NULL.
> The stale pointer will prevent kswapd_run() from creating a new work thread
> when adding memory to the memory-less NUMA node again. Eventually the stale
> pointer may cause invalid memory access.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Signed-off-by: Jiang Liu <liuj97@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
