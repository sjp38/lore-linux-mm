Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B68216B025E
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 11:00:33 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so59281579wms.7
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 08:00:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ia3si54513070wjb.276.2016.12.28.08.00.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 08:00:32 -0800 (PST)
Date: Wed, 28 Dec 2016 17:00:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20161228160029.GF11470@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <d957d4c5-3b58-c61f-0c95-c59e0326528c@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d957d4c5-3b58-c61f-0c95-c59e0326528c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <n.borisov.lkml@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 28-12-16 17:50:31, Nikolay Borisov wrote:
> 
> 
> On 28.12.2016 17:30, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> > from is file or anonymous but we do not know which LRU this is. It is
> > useful to know whether the list is file or anonymous as well. Change
>
> Maybe you wanted to say whether the list is ACTIVE/INACTIVE ?

You are right. I will update the wording to:
"
mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
from is file or anonymous but we do not know which LRU this is. It is
useful to know whether the list is active or inactive as well as we
use the same function to isolate pages for both of them. Change
the tracepoint to show symbolic names of the lru rather.
"

Does it sound better?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
