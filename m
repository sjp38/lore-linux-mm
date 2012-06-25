Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 7FE246B031F
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 04:48:57 -0400 (EDT)
Message-ID: <4FE82555.2010704@parallels.com>
Date: Mon, 25 Jun 2012 12:46:13 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: RFC:  Easy-Reclaimable LRU list
References: <4FE012CD.6010605@kernel.org>
In-Reply-To: <4FE012CD.6010605@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

On 06/19/2012 09:49 AM, Minchan Kim wrote:
> Hi everybody!
>
> Recently, there are some efforts to handle system memory pressure.
>
> 1) low memory notification - [1]
> 2) fallocate(VOLATILE) - [2]
> 3) fadvise(NOREUSE) - [3]
>
> For them, I would like to add new LRU list, aka "Ereclaimable" which is opposite of "unevictable".
> Reclaimable LRU list includes_easy_  reclaimable pages.
> For example, easy reclaimable pages are following as.
>
> 1. invalidated but remained LRU list.
> 2. pageout pages for reclaim(PG_reclaim pages)
> 3. fadvise(NOREUSE)
> 4. fallocate(VOLATILE)
>
> Their pages shouldn't stir normal LRU list and compaction might not migrate them, even.
What about other things moving memory like CMA ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
