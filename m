Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id B42256B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:56:31 -0400 (EDT)
Received: by ykdz80 with SMTP id z80so23012330ykd.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:56:31 -0700 (PDT)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id e188si3378003ywb.58.2015.08.28.10.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 10:56:31 -0700 (PDT)
Received: by ykay144 with SMTP id y144so7712672yka.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:56:30 -0700 (PDT)
Date: Fri, 28 Aug 2015 13:56:28 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828175628.GO26785@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828171322.GC21463@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828171322.GC21463@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello,

On Fri, Aug 28, 2015 at 07:13:22PM +0200, Michal Hocko wrote:
> On Fri 28-08-15 11:25:29, Tejun Heo wrote:
> > Currently, try_charge() tries to reclaim memory directly when the high
> > limit is breached; however, this has a couple issues.
> > 
> > * try_charge() can be invoked from any in-kernel allocation site and
> >   reclaim path may use considerable amount of stack.  This can lead to
> >   stack overflows which are extremely difficult to reproduce.
> 
> This is true but I haven't seen any reports for the stack overflow for
> quite some time.

So, this didn't really fix it but xfs had to punt things to workqueues
to avoid stack overflows and IIRC it involved direct reclaim.  Maybe
it's too late but it probably is a good idea to punt this from the
source.

> I would just argue that this implementation has the same issue as the
> other patch in the series which performs high-usage reclaim. I think
> that each task should reclaim only its contribution which is trivial
> to account.

Hmm... I'll respond there.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
