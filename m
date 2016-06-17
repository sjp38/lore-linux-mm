Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1D16B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:27:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so8445396wmr.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:27:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p1si11513774wjj.65.2016.06.17.04.27.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 04:27:12 -0700 (PDT)
Subject: Re: [PATCH 24/27] mm, page_alloc: Remove fair zone allocation policy
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-25-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9f30977a-ff07-d783-4c21-e13bd2478aa3@suse.cz>
Date: Fri, 17 Jun 2016 13:27:09 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-25-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> The fair zone allocation policy interleaves allocation requests between
> zones to avoid an age inversion problem whereby new pages are reclaimed
> to balance a zone. Reclaim is now node-based so this should no longer be
> an issue and the fair zone allocation policy is not free. This patch
> removes it.

I wonder if fair zone allocation had the side effect of preventing e.g. a small 
Normal zone to be almost fully occupied by long-lived unreclaimable allocations 
early in the kernel lifetime. So that might be one thing to watch out for. But 
otherwise I would agree it should be no longer needed with node-based reclaim.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
