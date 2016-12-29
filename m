Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB616B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:53:35 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id n189so551420891pga.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 21:53:35 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d7si52345589plj.257.2016.12.28.21.53.33
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 21:53:34 -0800 (PST)
Date: Thu, 29 Dec 2016 14:53:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/7] mm, vmscan: show the number of skipped pages in
 mm_vmscan_lru_isolate
Message-ID: <20161229055329.GB1815@bbox>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-4-mhocko@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20161228153032.10821-4-mhocko@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Dec 28, 2016 at 04:30:28PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> mm_vmscan_lru_isolate shows the number of requested, scanned and taken
> pages. This is mostly OK but on 32b systems the number of scanned pages
> is quite misleading because it includes both the scanned and skipped
> pages.  Moreover the skipped part is scaled based on the number of taken
> pages. Let's report the exact numbers without any additional logic and
> add the number of skipped pages. This should make the reported data much
> more easier to interpret.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
