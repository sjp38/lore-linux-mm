Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3C56B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:48:46 -0400 (EDT)
Received: by wijp15 with SMTP id p15so20136959wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:48:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si39541368wjx.103.2015.08.25.08.48.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 08:48:45 -0700 (PDT)
Subject: Re: [PATCH 07/12] mm, page_alloc: Distinguish between being unable to
 sleep, unwilling to sleep and avoiding waking kswapd
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC8E5B.9050304@suse.cz>
Date: Tue, 25 Aug 2015 17:48:43 +0200
MIME-Version: 1.0
In-Reply-To: <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/24/2015 02:09 PM, Mel Gorman wrote:
> The first key hazard to watch out for is callers that removed __GFP_WAIT
> and was depending on access to atomic reserves for inconspicuous reasons.
> In some cases it may be appropriate for them to use __GFP_HIGH.

Hm so I think this hazard should be expanded. If such caller comes from 
interrupt and doesn't use __GFP_ATOMIC, the ALLOC_CPUSET with 
restrictions taken from the interrupted process will also apply to him?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
