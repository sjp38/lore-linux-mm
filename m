Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF716B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 14:01:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a123so48931295qkd.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:01:52 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x6si5529778wmg.52.2016.07.12.11.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 11:01:51 -0700 (PDT)
Date: Tue, 12 Jul 2016 14:01:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 25/34] mm, vmscan: avoid passing in classzone_idx
 unnecessarily to compaction_ready
Message-ID: <20160712180141.GA7821@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-26-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-26-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:35:01AM +0100, Mel Gorman wrote:
> The scan_control structure has enough information available for
> compaction_ready() to make a decision. The classzone_idx manipulations in
> shrink_zones() are no longer necessary as the highest populated zone is
> no longer used to determine if shrink_slab should be called or not.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
