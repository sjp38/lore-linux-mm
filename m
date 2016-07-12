Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58C4E6B0253
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 14:43:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so19235973wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:43:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m131si3890998wmf.113.2016.07.12.11.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 11:43:44 -0700 (PDT)
Date: Tue, 12 Jul 2016 14:43:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 30/34] mm: page_alloc: cache the last node whose dirty
 limit is reached
Message-ID: <20160712184336.GA8629@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-31-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-31-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:35:06AM +0100, Mel Gorman wrote:
> If a page is about to be dirtied then the page allocator attempts to limit
> the total number of dirty pages that exists in any given zone.  The call
> to node_dirty_ok is expensive so this patch records if the last pgdat
> examined hit the dirty limits.  In some cases, this reduces the number of
> calls to node_dirty_ok().
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

I guess...

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
