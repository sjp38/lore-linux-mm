Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id A0F666B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 03:37:19 -0400 (EDT)
Date: Tue, 21 Aug 2012 16:37:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] memory hotplug: reset pgdat->kswapd to NULL if creating
 kernel thread fails
Message-ID: <20120821073738.GA24667@bbox>
References: <50332B37.2000500@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50332B37.2000500@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, hughd@google.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 21, 2012 at 02:31:19PM +0800, Wen Congyang wrote:
> If kthread_run() fails, pgdat->kswapd contains errno. When we stop
> this thread, we only check whether pgdat->kswapd is NULL and access
> it. If it contains errno, it will cause page fault. Reset pgdat->kswapd
> to NULL when creating kernel thread fails can avoid this problem.
> 
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

Nitpick: Why doesn't online_pages check kswapd_run's return value?
         I hope memory-hotplug can handle this error rightly without
         relying on this patch in the future.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
