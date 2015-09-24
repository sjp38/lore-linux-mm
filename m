Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2579082F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 16:05:14 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so128063007wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 13:05:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mn7si18687390wjc.178.2015.09.24.13.05.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 13:05:12 -0700 (PDT)
Date: Thu, 24 Sep 2015 16:05:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/10] mm, page_alloc: Remove unnecessary recalculations
 for dirty zone balancing
Message-ID: <20150924200504.GF3009@cmpxchg.org>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442832762-7247-3-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 21, 2015 at 11:52:34AM +0100, Mel Gorman wrote:
> File-backed pages that will be immediately written are balanced between
> zones.  This heuristic tries to avoid having a single zone filled with
> recently dirtied pages but the checks are unnecessarily expensive. Move
> consider_zone_balanced into the alloc_context instead of checking bitmaps
> multiple times. The patch also gives the parameter a more meaningful name.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
