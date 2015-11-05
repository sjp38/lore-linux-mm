Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id CAD1782F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 12:45:44 -0500 (EST)
Received: by iody8 with SMTP id y8so97617395iod.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 09:45:44 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id t12si7516279igd.27.2015.11.05.09.45.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 09:45:44 -0800 (PST)
Date: Thu, 5 Nov 2015 11:45:42 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <201511052359.JBB24816.FHtFOJOSLOVMQF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1511051144240.28554@east.gentwo.org>
References: <20151022143349.GD30579@mtj.duckdns.org> <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org> <20151022151414.GF30579@mtj.duckdns.org> <20151023042649.GB18907@mtj.duckdns.org> <20151102150137.GB3442@dhcp22.suse.cz>
 <201511052359.JBB24816.FHtFOJOSLOVMQF@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, htejun@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, 5 Nov 2015, Tetsuo Handa wrote:

> memory allocation. By allowing workqueue items to be processed (by using
> short sleep), some task might release memory when workqueue item is
> processed.
>
> Therefore, not only to keep vmstat counters up to date, but also for
> avoid wasting CPU cycles, I prefer a short sleep.

Sorry but we need work queue processing for vmstat counters that is
independent of other requests submitted that may block. Adding points
where we sleep / schedule everywhere to do this is not the right approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
