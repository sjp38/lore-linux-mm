Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id AF9F66B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:37:20 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l68so28366958wml.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:37:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 15si9731787wms.2.2016.03.03.02.37.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 02:37:19 -0800 (PST)
Subject: Re: [PATCH 01/27] mm, page_alloc: Use ac->classzone_idx instead of
 zone_idx(preferred_zone)
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-2-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D813DD.4050605@suse.cz>
Date: Thu, 3 Mar 2016 11:37:17 +0100
MIME-Version: 1.0
In-Reply-To: <1456239890-20737-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 02/23/2016 04:04 PM, Mel Gorman wrote:
> ac->classzone_idx is determined by the index of the preferred zone and cached
> to avoid repeated calculations. wake_all_kswapds() should use it instead of
> using zone_idx() within a loop.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
