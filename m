Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3694F6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:04:53 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w64so3824029iow.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:04:53 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id xk1si55715pab.53.2016.06.08.01.04.51
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 01:04:52 -0700 (PDT)
Date: Wed, 8 Jun 2016 17:03:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 06/10] mm: remove unnecessary use-once cache bias from
 LRU balancing
Message-ID: <20160608080358.GB28620@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-7-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160606194836.3624-7-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 03:48:32PM -0400, Johannes Weiner wrote:
> When the splitlru patches divided page cache and swap-backed pages
> into separate LRU lists, the pressure balance between the lists was
> biased to account for the fact that streaming IO can cause memory
> pressure with a flood of pages that are used only once. New page cache
> additions would tip the balance toward the file LRU, and repeat access
> would neutralize that bias again. This ensured that page reclaim would
> always go for used-once cache first.
> 
> Since e9868505987a ("mm,vmscan: only evict file pages when we have
> plenty"), page reclaim generally skips over swap-backed memory
> entirely as long as there is used-once cache present, and will apply
> the LRU balancing when only repeatedly accessed cache pages are left -
> at which point the previous use-once bias will have been neutralized.
> 
> This makes the use-once cache balancing bias unnecessary. Remove it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
