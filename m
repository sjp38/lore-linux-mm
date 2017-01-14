Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD5D76B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 11:16:53 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so21311966wmi.6
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:16:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u73si15247881wrc.271.2017.01.14.08.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 08:16:52 -0800 (PST)
Date: Sat, 14 Jan 2017 11:16:48 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 2/2] mm, vmscan: cleanup inactive_list_is_low
Message-ID: <20170114161648.GC26139@cmpxchg.org>
References: <20170110125552.4170-1-mhocko@kernel.org>
 <20170110125552.4170-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110125552.4170-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Tue, Jan 10, 2017 at 01:55:52PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> inactive_list_is_low is duplicating logic implemented by
> lruvec_lru_size_eligibe_zones. Let's use the dedicated function to get
> the number of eligible pages on the lru list and ask use lruvec_lru_size
> to get the total LRU lize only when the tracing is really requested. We
> are still iterating over all LRUs two times in that case but a)
> inactive_list_is_low is not a hot path and b) this can be addressed at
> the tracing layer and only evaluate arguments only when the tracing is
> enabled in future if that ever matters.

lruvec_zone_lru_size() is no longer needed after this. Again, it would
be better to consolidate everything into one lruvec_lru_size() that
takes a reclaim index. Trivial to rebase on top of that, though, so:

> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
