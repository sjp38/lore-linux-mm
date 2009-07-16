Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 921E46B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:49:34 -0400 (EDT)
Message-ID: <4A5F2FDA.2060309@redhat.com>
Date: Thu, 16 Jul 2009 09:49:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: count only reclaimable lru pages
References: <20090716133454.GA20550@localhost>
In-Reply-To: <20090716133454.GA20550@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> global_lru_pages() / zone_lru_pages() can be used in two ways:
> - to estimate max reclaimable pages in determine_dirtyable_memory()  
> - to calculate the slab scan ratio
> 
> When swap is full or not present, the anon lru lists are not reclaimable
> and thus won't be scanned. So the anon pages shall not be counted. Also
> rename the function names to reflect the new meaning.
> 
> It can greatly (and correctly) increase the slab scan rate under high memory
> pressure (when most file pages have been reclaimed and swap is full/absent),
> thus avoid possible false OOM kills.
> 
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
