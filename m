Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC916B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:15:42 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so13204476lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:15:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h25si21162907wmi.28.2016.07.12.08.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 08:15:41 -0700 (PDT)
Date: Tue, 12 Jul 2016 11:15:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 20/34] mm: move vmscan writes and file write accounting
 to the node
Message-ID: <20160712151537.GL5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-21-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-21-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:56AM +0100, Mel Gorman wrote:
> As reclaim is now node-based, it follows that page write activity due to
> page reclaim should also be accounted for on the node.  For consistency,
> also account page writes and page dirtying on a per-node basis.
> 
> After this patch, there are a few remaining zone counters that may appear
> strange but are fine.  NUMA stats are still per-zone as this is a
> user-space interface that tools consume.  NR_MLOCK, NR_SLAB_*,
> NR_PAGETABLE, NR_KERNEL_STACK and NR_BOUNCE are all allocations that
> potentially pin low memory and cannot trivially be reclaimed on demand.
> This information is still useful for debugging a page allocation failure
> warning.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

More conversion... ;) FWIW, I didn't spot anything problematic. And
agreed with leaving unmovable stuff counters on a per-zone basis.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
