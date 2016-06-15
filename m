Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE3E6B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:23:15 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so10520466lbb.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:23:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t137si11009341wme.74.2016.06.15.07.23.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Jun 2016 07:23:14 -0700 (PDT)
Subject: Re: [PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-7-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0973a4bd-ec85-b6f2-02a4-25b787675e01@suse.cz>
Date: Wed, 15 Jun 2016 16:23:12 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-7-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Patch "mm: vmscan: Begin reclaiming pages on a per-node basis" started
> thinking of reclaim in terms of nodes but kswapd is still zone-centric. This
> patch gets rid of many of the node-based versus zone-based decisions.
>
> o A node is considered balanced when any eligible lower zone is balanced.
>   This eliminates one class of age-inversion problem because we avoid
>   reclaiming a newer page just because it's in the wrong zone
> o pgdat_balanced disappears because we now only care about one zone being
>   balanced.
> o Some anomalies related to writeback and congestion tracking being based on
>   zones disappear.
> o kswapd no longer has to take care to reclaim zones in the reverse order
>   that the page allocator uses.
> o Most importantly of all, reclaim from node 0 with multiple zones will
>   have similar aging and reclaiming characteristics as every
>   other node.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
