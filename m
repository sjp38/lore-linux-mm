Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5C61B6B0037
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:14:44 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id v15so1760530bkz.0
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 14:14:43 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ln4si4741867bkb.188.2014.01.10.14.14.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 14:14:43 -0800 (PST)
Date: Fri, 10 Jan 2014 17:14:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20140110221432.GD6963@cmpxchg.org>
References: <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com>
 <20131218200434.GA4161@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
 <20131219144134.GH10855@dhcp22.suse.cz>
 <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
 <alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com>
 <20140109144757.e95616b4280c049b22743a15@linux-foundation.org>
 <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com>
 <20140109161246.57ea590f00ea5b61fdbf5f11@linux-foundation.org>
 <alpine.DEB.2.02.1401091613560.22649@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401091613560.22649@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, Jan 09, 2014 at 04:23:50PM -0800, David Rientjes wrote:
> On Thu, 9 Jan 2014, Andrew Morton wrote:
> 
> > > > It was dropped because the other memcg developers disagreed with it.
> > > > 
> > > 
> > > It was acked-by Michal.

Michal acked it before we had most of the discussions and now he is
proposing an alternate version of yours, a patch that you are even
discussing with him concurrently in another thread.  To claim he is
still backing your patch because of that initial ack is disingenuous.

> > And Johannes?
> > 
> 
> Johannes is arguing for the same semantics that VMPRESSURE_CRITICAL and/or 
> memory thresholds provides, which disagrees from the list of solutions 
> that Documentation/cgroups/memory.txt gives for userspace oom handler 
> wakeups and is required for any sane implementation.

No, he's not and I'm sick of you repeating refuted garbage like this.

You have convinced neither me nor Michal that your problem is entirely
real and when confronted with doubt you just repeat the same points
over and over.

The one aspect of your change that we DO agree is valid is now fixed
by Michal in a separate attempt because you could not be bothered to
incorporate feedback into your patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
