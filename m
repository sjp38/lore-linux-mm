Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA984402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:45:00 -0500 (EST)
Received: by padhx2 with SMTP id hx2so63730927pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:44:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c5si2370156pas.41.2015.11.25.09.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 09:44:59 -0800 (PST)
Date: Wed, 25 Nov 2015 18:44:49 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/2] memcg: flatten task_struct->memcg_oom
Message-ID: <20151125174449.GD17308@twins.programming.kicks-ass.net>
References: <20150913185940.GA25369@htj.duckdns.org>
 <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net>
 <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mhocko@kernel.org, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, vdavydov@parallels.com, kernel-team@fb.com, Dmitry Vyukov <dvyukov@google.com>

On Wed, Nov 25, 2015 at 06:31:41PM +0300, Andrey Ryabinin wrote:
> > +       /* scheduler bits, serialized by scheduler locks */
> >         unsigned sched_reset_on_fork:1;
> >         unsigned sched_contributes_to_load:1;
> >         unsigned sched_migrated:1;
> > +       unsigned __padding_sched:29;
> 
> AFAIK the order of bit fields is implementation defined, so GCC could
> sort all these bits as it wants.

We're relying on it doing DTRT in other places, so I'm fairly confident
this'll work, otoh

> You could use unnamed zero-widht bit-field to force padding:
> 
>          unsigned :0; //force aligment to the next boundary.

That's a nice trick I was not aware of, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
