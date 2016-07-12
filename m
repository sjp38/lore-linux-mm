Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8407D6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:54:40 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so11393433lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:54:40 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s133si20729956wms.104.2016.07.12.06.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 06:54:39 -0700 (PDT)
Date: Tue, 12 Jul 2016 09:54:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/34] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160712135435.GB5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-6-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-6-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:41AM +0100, Mel Gorman wrote:
> This patch makes reclaim decisions on a per-node basis.  A reclaimer knows
> what zone is required by the allocation request and skips pages from
> higher zones.  In many cases this will be ok because it's a GFP_HIGHMEM
> request of some description.  On 64-bit, ZONE_DMA32 requests will cause
> some problems but 32-bit devices on 64-bit platforms are increasingly
> rare.  Historically it would have been a major problem on 32-bit with big
> Highmem:Lowmem ratios but such configurations are also now rare and even
> where they exist, they are not encouraged.  If it really becomes a
> problem, it'll manifest as very low reclaim efficiencies.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
