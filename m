Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93D7A6B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:39:49 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so39978729lbb.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:39:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tk4si11817703wjb.199.2016.06.17.05.39.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 05:39:48 -0700 (PDT)
Subject: Re: [PATCH 27/27] mm: vmstat: Account per-zone stalls and pages
 skipped during reclaim
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-28-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a72ece1f-e481-f1cd-7072-e7d021754094@suse.cz>
Date: Fri, 17 Jun 2016 14:39:46 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-28-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> The vmstat allocstall was fairly useful in the general sense but
> node-based LRUs change that. It's important to know if a stall was for an
> address-limited allocation request as this will require skipping pages from
> other zones. This patch adds pgstall_* counters to replace allocstall. The
> sum of the counters will equal the old allocstall so it can be trivially
> recalculated. A high number of address-limited allocation requests may
> result in a lot of useless LRU scanning for suitable pages.
>
> As address-limited allocations require pages to be skipped, it's important
> to know how much useless LRU scanning took place so this patch adds
> pgskip* counters. This yields the following model
>
> 1. The number of address-space limited stalls can be accounted for (pgstall)
> 2. The amount of useless work required to reclaim the data is accounted (pgskip)
> 3. The total number of scans is available from pgscan_kswapd and pgscan_direct
>    so from that the ratio of useful to useless scans can be calculated.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Nice work!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
