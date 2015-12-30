Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id A44766B0263
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 15:41:42 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id b35so60963524qge.0
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:41:42 -0800 (PST)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id 197si76945695qha.88.2015.12.30.12.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 12:41:42 -0800 (PST)
Received: by mail-qk0-x230.google.com with SMTP id p186so16580949qke.0
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:41:42 -0800 (PST)
Date: Wed, 30 Dec 2015 15:41:40 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4.4-rc7] sched: isolate task_struct bitfields according
 to synchronization domains
Message-ID: <20151230204140.GA17398@htj.duckdns.org>
References: <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net>
 <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
 <20151125174449.GD17308@twins.programming.kicks-ass.net>
 <20151211162554.GS30240@mtj.duckdns.org>
 <20151215192245.GK6357@twins.programming.kicks-ass.net>
 <20151230092337.GD3873@htj.duckdns.org>
 <CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov@parallels.com>, kernel-team <kernel-team@fb.com>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>

Hello, Linus.

On Wed, Dec 30, 2015 at 12:10:12PM -0800, Linus Torvalds wrote:
> On Wed, Dec 30, 2015 at 1:23 AM, Tejun Heo <tj@kernel.org> wrote:
> >
> > Peter, I took the patch and changed the bitfields to ulong.
> 
> I wouldn't expect the unsigned long part to matter, except for the
> forced split with

Right, I was thinking alpha was doing rmw's for things smaller than
64bit.  That's 32bit, not 64.

>    unsigned long :0;
> 
> itself.
> 
> Also, quite frankly, since this is basically very close to other
> fields that are *not* unsigned longs, I'd really prefer to not
> unnecessarily use a 64-bit field for three bits each.
> 
> So why not just do it with plain unsigned "int", and then maybe just
> intersperse them with the other int-sized fields in that neighborhood.
>
> I'm also wondering if we shouldn't just put the scheduler bits in the
> "atomic_flags" thing instead?

Sure.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
