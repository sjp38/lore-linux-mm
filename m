Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A38066B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 01:41:40 -0400 (EDT)
Received: by yenr5 with SMTP id r5so726999yen.14
        for <linux-mm@kvack.org>; Wed, 13 Jun 2012 22:41:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339645491-5656-1-git-send-email-jiang.liu@huawei.com>
References: <1339645491-5656-1-git-send-email-jiang.liu@huawei.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 14 Jun 2012 01:41:19 -0400
Message-ID: <CAHGf_=r+XnzfBD3EWe9O7iQqSPLwD5ijP5FtBHsc88mTm8mRrA@mail.gmail.com>
Subject: Re: [PATCH] memory hotplug: fix invalid memory access caused by stale
 kswapd pointer
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Keping Chen <chenkeping@huawei.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <liuj97@gmail.com>

On Wed, Jun 13, 2012 at 11:44 PM, Jiang Liu <jiang.liu@huawei.com> wrote:
> Function kswapd_stop() will be called to destroy the kswapd work thread
> when all memory of a NUMA node has been offlined. But kswapd_stop() only
> terminates the work thread without resetting NODE_DATA(nid)->kswapd to NULL.
> The stale pointer will prevent kswapd_run() from creating a new work thread
> when adding memory to the memory-less NUMA node again. Eventually the stale
> pointer may cause invalid memory access.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Signed-off-by: Jiang Liu <liuj97@gmail.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
