Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48C866B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 16:24:29 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id an2so7944025wjc.3
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 13:24:29 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b203si3354258wme.154.2017.02.03.13.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 13:24:28 -0800 (PST)
Date: Fri, 3 Feb 2017 16:24:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, vmscan: Clear PGDAT_WRITEBACK when zone is balanced
Message-ID: <20170203212411.GA12133@cmpxchg.org>
References: <20170203203222.gq7hk66yc36lpgtb@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170203203222.gq7hk66yc36lpgtb@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'Michal Hocko' <mhocko@suse.com>, 'Minchan Kim' <minchan.kim@gmail.com>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 03, 2017 at 08:32:22PM +0000, Mel Gorman wrote:
> Hillf Danton pointed out that since commit 1d82de618dd ("mm, vmscan:
> make kswapd reclaim in terms of nodes") that PGDAT_WRITEBACK is no longer
> cleared. It was not noticed as triggering it requires pages under writeback
> to cycle twice through the LRU and before kswapd gets stalled. Historically,
> such issues tended to occur on small machines writing heavily to slow
> storage such as a USB stick. Once kswapd stalls, direct reclaim stalls may
> be higher but due to the fact that memory pressure is requires, it would not
> be very noticable. Michal Hocko suggested removing the flag entirely but
> the conservative fix is to restore the intended PGDAT_WRITEBACK behaviour
> and clear the flag when a suitable zone is balanced.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
