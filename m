Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B0BCF6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 04:55:04 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so14112682wmd.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:55:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e68si1514042wmd.117.2017.01.13.01.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 01:55:03 -0800 (PST)
Subject: Re: [PATCH] mm, vmscan: do not count freed pages as PGDEACTIVATE
References: <20170112211221.17636-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2ebf38a0-d8b3-c4bb-3351-b6053332a116@suse.cz>
Date: Fri, 13 Jan 2017 10:55:00 +0100
MIME-Version: 1.0
In-Reply-To: <20170112211221.17636-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 01/12/2017 10:12 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> PGDEACTIVATE represents the number of pages moved from the active list
> to the inactive list. At least this sounds like the original motivation
> of the counter. move_active_pages_to_lru, however, counts pages which
> got freed in the mean time as deactivated as well. This is a very rare
> event and counting them as deactivation in itself is not harmful but it
> makes the code more convoluted than necessary - we have to count both
> all pages and those which are freed which is a bit confusing.
>
> After this patch the PGDEACTIVATE should have a slightly more clear
> semantic and only count those pages which are moved from the active to
> the inactive list which is a plus.
>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
