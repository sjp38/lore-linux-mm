Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDAD86B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:32:39 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so12196584lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:32:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i81si3734528wmd.107.2016.07.12.07.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:32:38 -0700 (PDT)
Date: Tue, 12 Jul 2016 10:32:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 13/34] mm, vmscan: make shrink_node decisions more
 node-centric
Message-ID: <20160712143234.GG5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-14-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-14-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:49AM +0100, Mel Gorman wrote:
> Earlier patches focused on having direct reclaim and kswapd use data that
> is node-centric for reclaiming but shrink_node() itself still uses too
> much zone information.  This patch removes unnecessary zone-based
> information with the most important decision being whether to continue
> reclaim or not.  Some memcg APIs are adjusted as a result even though
> memcg itself still uses some zone information.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Second half of the memcg conversion is in the next patch. Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
