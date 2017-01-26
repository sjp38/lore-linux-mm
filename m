Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8AE6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 20:38:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so291666028pgd.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:38:16 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 140si11252321pgg.95.2017.01.25.17.38.14
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 17:38:15 -0800 (PST)
Date: Thu, 26 Jan 2017 10:38:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/5] mm: vmscan: remove old flusher wakeup from direct
 reclaim path
Message-ID: <20170126013806.GC21211@bbox>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-4-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20170123181641.23938-4-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:39PM -0500, Johannes Weiner wrote:
> Direct reclaim has been replaced by kswapd reclaim in pretty much all
> common memory pressure situations, so this code most likely doesn't
> accomplish the described effect anymore. The previous patch wakes up
> flushers for all reclaimers when we encounter dirty pages at the tail
> end of the LRU. Remove the crufty old direct reclaim invocation.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
