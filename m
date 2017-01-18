Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2C746B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:42:52 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id ez4so4092888wjd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:42:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si3365930wms.53.2017.01.18.10.42.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 10:42:51 -0800 (PST)
Date: Wed, 18 Jan 2017 19:42:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
Message-ID: <20170118184246.GC17135@dhcp22.suse.cz>
References: <20161220134904.21023-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161220134904.21023-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 20-12-16 14:49:01, Michal Hocko wrote:
> Hi,
> This has been posted [1] initially to later be reduced to a single patch
> [2].  Johannes then suggested [3] to split up the second patch and make
> the access to memory reserves by __GF_NOFAIL requests which do not
> invoke the oom killer a separate change. This is patch 3 now.
> 
> Tetsuo has noticed [4] that recent changes have changed GFP_NOFAIL
> semantic for costly order requests. I believe that the primary reason
> why this happened is that our GFP_NOFAIL checks are too scattered
> and it is really easy to forget about adding one. That's why I am
> proposing patch 1 which consolidates all the nofail handling at a single
> place. This should help to make this code better maintainable.
> 
> Patch 2 on top is a further attempt to make GFP_NOFAIL semantic less
> surprising. As things stand currently GFP_NOFAIL overrides the oom killer
> prevention code which is both subtle and not really needed. The patch 2
> has more details about issues this might cause. We have also seen
> a report where __GFP_NOFAIL|GFP_NOFS requests cause the oom killer which
> is premature.
> 
> Patch 3 is an attempt to reduce chances of GFP_NOFAIL requests being
> preempted by other memory consumers by giving them access to memory
> reserves.
> 
> [1] http://lkml.kernel.org/r/20161123064925.9716-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20161214150706.27412-1-mhocko@kernel.org
> [3] http://lkml.kernel.org/r/20161216173151.GA23182@cmpxchg.org
> [4] http://lkml.kernel.org/r/1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

Friendly ping on this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
