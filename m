Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 20B696B0254
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:20:39 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id cy9so30542283pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:20:39 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id cc5si19665686pad.168.2016.01.28.15.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 15:20:38 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id cy9so30542172pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:20:38 -0800 (PST)
Date: Thu, 28 Jan 2016 15:20:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/3] mm, vmscan: make zone_reclaimable_pages more
 precise
In-Reply-To: <1454015979-9985-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1601281520250.31035@chino.kir.corp.google.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <1454015979-9985-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, 28 Jan 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> zone_reclaimable_pages is used in should_reclaim_retry which uses it to
> calculate the target for the watermark check. This means that precise
> numbers are important for the correct decision. zone_reclaimable_pages
> uses zone_page_state which can contain stale data with per-cpu diffs
> not synced yet (the last vmstat_update might have run 1s in the past).
> 
> Use zone_page_state_snapshot in zone_reclaimable_pages instead. None
> of the current callers is in a hot path where getting the precise value
> (which involves per-cpu iteration) would cause an unreasonable overhead.
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
