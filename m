Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A5A1F6B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 05:06:21 -0400 (EDT)
Message-ID: <4FE1915B.3040303@huawei.com>
Date: Wed, 20 Jun 2012 17:01:15 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] trivial, memory hotplug: add kswapd_is_running() for
 better readability
References: <4FD97718.6060008@kernel.org> <1339663776-196-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1206161913370.797@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206161913370.797@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

> This isn't better, there's no functional change and you've just added a 
> second conditional for no reason and an unnecessary kswapd_is_running() 
> function.
> 
> More concerning is that online_pages() doesn't check the return value of 
> kswapd_run().  We should probably fail the memory hotplug operation that 
> onlines a new node and doesn't have a kswapd running and cleanup after 
> ourselves in online_pages() with some sane error handling.

Hi David,
	Good points! Is it feasible to use schedule_delayed_work_on() to
retry kswapd_run() instead of ralling back the online operation in case
kswapd_run() failed to create the work thread?
	Thank!
	Gerry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
