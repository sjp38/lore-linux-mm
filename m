Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 34FDD6B026F
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:22:23 -0500 (EST)
Received: by wmec201 with SMTP id c201so268138133wme.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:22:22 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id m12si3513065wmg.108.2015.11.18.01.22.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 01:22:21 -0800 (PST)
Received: by wmww144 with SMTP id w144so62852936wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:22:21 -0800 (PST)
Date: Wed, 18 Nov 2015 10:22:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: do not loop over ALLOC_NO_WATERMARKS without
 triggering reclaim
Message-ID: <20151118092220.GC19145@dhcp22.suse.cz>
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-3-git-send-email-mhocko@kernel.org>
 <564B0841.6030409@I-love.SAKURA.ne.jp>
 <20151118091101.GA19145@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151118091101.GA19145@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-11-15 10:11:01, Michal Hocko wrote:
> Besides that I fail to see why a work item would ever
> want to set PF_MEMALLOC for legitimate reasons. I have done a quick git
> grep over the tree and there doesn't seem to be any user.

OK, I have missed one case. xfs_btree_split_worker is really setting
PF_MEMALLOC from the worker context basically to inherit the flag from
kswapd. This is a legitimate use but it doesn't affect the allocation
path so it is not related to this discussion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
