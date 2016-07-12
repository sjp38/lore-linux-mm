Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 70D5B6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 13:24:52 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so16206261lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:24:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p18si4688961wmd.144.2016.07.12.10.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 10:24:51 -0700 (PDT)
Date: Tue, 12 Jul 2016 13:24:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 22/34] mm, page_alloc: wake kswapd based on the highest
 eligible zone
Message-ID: <20160712172446.GB7307@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-23-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-23-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:58AM +0100, Mel Gorman wrote:
> The ac_classzone_idx is used as the basis for waking kswapd and that is based
> on the preferred zoneref. If the preferred zoneref's first zone is lower
> than what is available on other nodes, it's possible that kswapd is woken
> on a zone with only higher, but still eligible, zones. As classzone_idx
> is strictly adhered to now, it causes a problem because eligible pages
> are skipped.
> 
> For example, node 0 has only DMA32 and node 1 has only NORMAL. An allocating
> context running on node 0 may wake kswapd on node 1 telling it to skip
> all NORMAL pages.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
