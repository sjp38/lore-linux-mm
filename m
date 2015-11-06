Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id C2ECE82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 07:56:30 -0500 (EST)
Received: by ioc74 with SMTP id 74so57230998ioc.2
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 04:56:30 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id v10si590724igz.2.2015.11.06.04.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 06 Nov 2015 04:56:30 -0800 (PST)
Date: Fri, 6 Nov 2015 06:56:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
In-Reply-To: <201511062028.DFE13506.MtVSOOFJLFOHQF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1511060656010.21658@east.gentwo.org>
References: <20151029022447.GB27115@mtj.duckdns.org> <20151029030822.GD27115@mtj.duckdns.org> <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org> <201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
 <201511062028.DFE13506.MtVSOOFJLFOHQF@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: htejun@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Fri, 6 Nov 2015, Tetsuo Handa wrote:

> So, if you refer to the blocking of the execution of vmstat updates,
> description for patch 3/3 sould be updated to something like below?

Ok that is much better.

> ----------
> Since __GFP_WAIT memory allocations do not call schedule()
> when there is nothing to reclaim, and workqueue does not kick
> remaining workqueue items unless in-flight workqueue item calls
> schedule(), __GFP_WAIT memory allocation requests by workqueue
> items can block vmstat_update work item forever.
>
> Since zone_reclaimable() decision depends on vmstat counters
> to be up to dated, a silent lockup occurs because a workqueue
> item doing a __GFP_WAIT memory allocation request continues
> using outdated vmstat counters.
>
> In order to fix this problem, we need to allocate a dedicated
> workqueue for vmstat. Note that this patch itself does not fix
> lockup problem. Tejun will develop a patch which detects lockup
> situation and kick remaining workqueue items.
> ----------
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
