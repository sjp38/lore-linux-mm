Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1D4D6B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 03:53:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a7so17634365pfj.3
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 00:53:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q127si9021389pga.19.2017.10.03.00.53.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 00:53:59 -0700 (PDT)
Date: Tue, 3 Oct 2017 08:53:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm, hugetlb: drop hugepages_treat_as_movable sysctl
Message-ID: <20171003075354.gni4jsb6ag2j4odn@suse.de>
References: <20171003072619.8654-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171003072619.8654-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexandru Moise <00moses.alexander00@gmail.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Tue, Oct 03, 2017 at 09:26:19AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> hugepages_treat_as_movable has been introduced by 396faf0303d2 ("Allow
> huge page allocations to use GFP_HIGH_MOVABLE") to allow hugetlb
> allocations from ZONE_MOVABLE even when hugetlb pages were not
> migrateable. The purpose of the movable zone was different at the time.
> It aimed at reducing memory fragmentation and hugetlb pages being long
> lived and large werre not contributing to the fragmentation so it was
> acceptable to use the zone back then.
> 

Well, primarily it was aimed at allowing the hugetlb pool to safely shrink
with the ability to grow it again. The use case was for batched jobs,
some of which needed huge pages and others that did not but didn't want
the memory useless pinned in the huge pages pool.

> Things have changed though and the primary purpose of the zone became
> migratability guarantee. If we allow non migrateable hugetlb pages to
> be in ZONE_MOVABLE memory hotplug might fail to offline the memory.
> 
> Remove the knob and only rely on hugepage_migration_supported to allow
> movable zones.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I suspect that more users rely on THP than hugetlbfs for flexible use
of huge pages with fallback options so I think that removing the option
should be ok.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
