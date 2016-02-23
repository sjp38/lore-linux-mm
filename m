Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CF36F6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:04:48 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so212420129wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:04:48 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s1si22600674wjf.66.2016.02.23.10.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:04:47 -0800 (PST)
Date: Tue, 23 Feb 2016 10:04:36 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/27] mm, page_alloc: Use ac->classzone_idx instead of
 zone_idx(preferred_zone)
Message-ID: <20160223180436.GA13816@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456239890-20737-2-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 03:04:24PM +0000, Mel Gorman wrote:
> ac->classzone_idx is determined by the index of the preferred zone and cached
> to avoid repeated calculations. wake_all_kswapds() should use it instead of
> using zone_idx() within a loop.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
