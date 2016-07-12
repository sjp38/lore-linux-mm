Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC70F6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:38:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so15058962wme.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:38:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h78si3939388lfe.413.2016.07.12.07.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:38:36 -0700 (PDT)
Date: Tue, 12 Jul 2016 10:38:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 14/34] mm, memcg: move memcg limit enforcement from zones
 to nodes
Message-ID: <20160712143828.GH5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-15-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-15-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:50AM +0100, Mel Gorman wrote:
> Memcg needs adjustment after moving LRUs to the node. Limits are tracked
> per memcg but the soft-limit excess is tracked per zone. As global page
> reclaim is based on the node, it is easy to imagine a situation where
> a zone soft limit is exceeded even though the memcg limit is fine.
> 
> This patch moves the soft limit tree the node.  Technically, all the variable
> names should also change but people are already familiar by the meaning of
> "mz" even if "mn" would be a more appropriate name now.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Michal Hocko <mhocko@suse.com>

Yep, the soft limit tracking scope needs to match the reclaim scope.

Nice patch :)

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
