Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 22DC76B0255
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:41:15 -0400 (EDT)
Received: by oifu63 with SMTP id u63so5730020oif.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:41:14 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id y128si8938575oig.67.2015.10.22.07.41.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Oct 2015 07:41:14 -0700 (PDT)
Date: Thu, 22 Oct 2015 09:41:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
In-Reply-To: <20151022143349.GD30579@mtj.duckdns.org>
Message-ID: <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
References: <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org> <20151021145505.GE8805@dhcp22.suse.cz> <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org> <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp> <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org> <20151022142155.GB30579@mtj.duckdns.org> <alpine.DEB.2.20.1510220923130.23591@east.gentwo.org> <20151022142429.GC30579@mtj.duckdns.org> <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
 <20151022143349.GD30579@mtj.duckdns.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, 22 Oct 2015, Tejun Heo wrote:

> The only way to hang the execution for a work item w/ WQ_MEM_RECLAIM
> is to create a cyclic dependency on another work item and keep that
> work item busy wait.  Workqueue thinks that work item is making
> progress as it's running and doesn't schedule the next one.
>
> (I was misremembering here) HIGHPRI originally was implemented
> head-queueing on the same pool followed by immediate execution, so
> could get around cases where this could happen, but that got lost
> while converting it to a separate pool.  I can introduce another flag
> to bypass concurrency management if necessary (it's kinda trivial) but
> busy-waiting cyclic dependency is a pretty unusual thing.
>
> If this is actually a legit busy-waiting cyclic dependency, just let
> me know.

There is no dependency of the vmstat updater on anything.
They can run anytime. If there is a dependency then its created by the
kworker subsystem itself.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
