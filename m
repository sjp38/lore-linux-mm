Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EC1886008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 14:47:24 -0400 (EDT)
Message-ID: <4BF4322A.3000507@redhat.com>
Date: Wed, 19 May 2010 14:47:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs: Insert tmpfs cache pages to inactive list at first
References: <20100519174327.9591.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100519174327.9591.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 05/19/2010 04:44 AM, KOSAKI Motohiro wrote:
> Shaohua Li reported parallel file copy on tmpfs can lead to
> OOM killer. This is regression of caused by commit 9ff473b9a7
> (vmscan: evict streaming IO first). Wow, It is 2 years old patch!

> Thus, now we can use lru_cache_add_anon() instead.
>
> Reported-by: Shaohua Li<shaohua.li@intel.com>
> Cc: Wu Fengguang<fengguang.wu@intel.com>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Minchan Kim<minchan.kim@gmail.com>
> Cc: Hugh Dickins<hughd@google.com>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
