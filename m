Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 614AB6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:04:47 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4815569pbb.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:04:46 -0700 (PDT)
Date: Fri, 15 Jun 2012 00:04:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] trivial, memory hotplug: add kswapd_is_running() for
 better readability
Message-ID: <20120614150434.GC2097@barrios>
References: <4FD97718.6060008@kernel.org>
 <1339663776-196-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339663776-196-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Thu, Jun 14, 2012 at 04:49:36PM +0800, Jiang Liu wrote:
> Add kswapd_is_running() to check whether the kswapd worker thread is already
> running before calling kswapd_run() when onlining memory pages.
> 
> It's based on a draft version from Minchan Kim <minchan@kernel.org>.
> 
> Signed-off-by: Jiang Liu <liuj97@gmail.com>

Reviewed-by: Minchan Kim <minchan@kernel.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
