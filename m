Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id B2C546B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 19:05:07 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so6207947yhn.32
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 16:05:07 -0800 (PST)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id y62si37861744yhc.169.2013.11.29.16.05.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 16:05:06 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so7001178yhz.22
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 16:05:06 -0800 (PST)
Date: Fri, 29 Nov 2013 16:05:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131128100213.GE2761@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311291600290.22413@chino.kir.corp.google.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org> <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com> <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com> <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com> <20131128031313.GK3556@cmpxchg.org> <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com> <20131128100213.GE2761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 28 Nov 2013, Michal Hocko wrote:

> > None that I am currently aware of,
> 
> Are you saing that scenarios described in 3812c8c8f395 (mm: memcg: do not
> trap chargers with full callstack on OOM) are not real or that _you_
> haven't seen an issue like that?
> 
> The later doesn't seem to be so relevant as we had at least one user who
> has seen those in the real life.
> 

I said I'm not currently aware of any additional problems with the 
patchset, but since Johannes said the entire series wasn't meant for that 
merge window, I asked if it was still being worked on.

> > You don't think something like this is helpful after scanning a memcg will 
> > a large number of processes?
> 
> It looks as a one-shot workaround for short lived processes to me.

It has nothing to do with how long a process has been running, both racing 
processes could have been running for years.  It's obvious that even this 
patch before calling oom_kill_process() does not catch a racing process 
that has already freed its memory and is exiting but it makes the 
liklihood significantly less in testing at scale.  It's simply better to 
avoid unnecessary oom killing at anytime possible and this is not a 
hotpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
