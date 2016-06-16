Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8E86B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 11:53:02 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id c1so10827260lbw.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 08:53:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si4989912wme.94.2016.06.16.08.53.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 08:53:00 -0700 (PDT)
Subject: Re: [PATCH 16/27] mm: Move page mapped accounting to the node
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-17-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5c8812fc-f2d3-3008-74ba-9072ae8c7cb3@suse.cz>
Date: Thu, 16 Jun 2016 17:52:59 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-17-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> Reclaim makes decisions based on the number of file pages that are mapped but
> it's mixing node and zone information. Account NR_FILE_MAPPED pages on the node.

And NR_ANON_PAGES.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

I've noticed some new "page_zone(page)->zone_pgdat" instances here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
