Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3EB6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 12:02:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so37398794wma.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 09:02:18 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ee5si1371566wjd.276.2016.07.22.09.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 09:02:17 -0700 (PDT)
Date: Fri, 22 Jul 2016 12:02:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/5] mm, vmscan: Account for skipped pages as a partial
 scan
Message-ID: <20160722160212.GE23650@cmpxchg.org>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <1469110261-7365-6-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469110261-7365-6-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 03:11:01PM +0100, Mel Gorman wrote:
> Page reclaim determines whether a pgdat is unreclaimable by examining how
> many pages have been scanned since a page was freed and comparing that to
> the LRU sizes. Skipped pages are not reclaim candidates but contribute to
> scanned. This can prematurely mark a pgdat as unreclaimable and trigger
> an OOM kill.
> 
> This patch accounts for skipped pages as a partial scan so that an
> unreclaimable pgdat will still be marked as such but by scaling the cost
> of a skip, it'll avoid the pgdat being marked prematurely.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
