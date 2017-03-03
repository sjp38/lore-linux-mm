Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0126B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 03:04:22 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u108so24516043wrb.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 00:04:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si13779774wra.226.2017.03.03.00.04.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 00:04:21 -0800 (PST)
Date: Fri, 3 Mar 2017 09:04:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
Message-ID: <20170303080419.GA31582@dhcp22.suse.cz>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
 <20170301154659.GL6515@twins.programming.kicks-ass.net>
 <20170301160529.GI11730@dhcp22.suse.cz>
 <20170301161220.GP6515@twins.programming.kicks-ass.net>
 <20170301161854.GJ11730@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301161854.GJ11730@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nikolay Borisov <nborisov@suse.com>, linux-kernel@vger.kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Wed 01-03-17 17:18:54, Michal Hocko wrote:
> On Wed 01-03-17 17:12:20, Peter Zijlstra wrote:
> > On Wed, Mar 01, 2017 at 05:05:30PM +0100, Michal Hocko wrote:
> > > Anyway, does the following help?
> > 
> > > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > > index 47e4f82380e4..d5386ad7ed3f 100644
> > > --- a/kernel/locking/lockdep.c
> > > +++ b/kernel/locking/lockdep.c
> > > @@ -47,6 +47,7 @@
> > >  #include <linux/kmemcheck.h>
> > >  #include <linux/random.h>
> > >  #include <linux/jhash.h>
> > > +#include <linux/sched.h>
> > 
> > No, Ingo moved that to linux/sched/mm.h in tip/master, which was the
> > problem.
> 
> Yeah, have seen your email after I posted mine...
> 
> > But I think this needs to go to Linus in this cycle, right? In which
> > case Ingo gets to sort the fallout.
> 
> Yes I think it would be better to send it sonner rahter than later.
> People also might want to backport it to older kernels...

Would you mind if I took this patch and route it via Andrew? I plan to
resubmit my scope NOFS patchset [1] and [2] will need to be refreshed on
top of it so it would be easier for me that way.

[1] http://lkml.kernel.org/r/20170206140718.16222-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170206140718.16222-4-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
