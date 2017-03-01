Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2346B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:17:39 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y187so17372524wmy.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:17:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v41si6935741wrc.210.2017.03.01.07.17.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:17:38 -0800 (PST)
Date: Wed, 1 Mar 2017 15:17:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/9] mm: remove seemingly spurious reclaimability check
 from laptop_mode gating
Message-ID: <20170301151732.GC4359@suse.de>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170228214007.5621-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Feb 28, 2017 at 04:40:01PM -0500, Johannes Weiner wrote:
> 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> allowed laptop_mode=1 to start writing not just when the priority
> drops to DEF_PRIORITY - 2 but also when the node is unreclaimable.
> That appears to be a spurious change in this patch as I doubt the
> series was tested with laptop_mode,

laptop_mode was not tested.

> and neither is that particular
> change mentioned in the changelog. Remove it, it's still recent.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
