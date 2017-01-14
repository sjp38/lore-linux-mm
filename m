Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1186B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 11:39:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id p192so21621662wme.1
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:39:15 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t3si6191493wmd.79.2017.01.14.08.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 08:39:13 -0800 (PST)
Date: Sat, 14 Jan 2017 11:39:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, vmscan: do not count freed pages as PGDEACTIVATE
Message-ID: <20170114163908.GH26139@cmpxchg.org>
References: <20170112211221.17636-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112211221.17636-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Jan 12, 2017 at 10:12:21PM +0100, Michal Hocko wrote:
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

I bet it's a small inaccuracy in practice, but now that the trace
patches added a proper counter, might as well consolidate into the
correct one.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
