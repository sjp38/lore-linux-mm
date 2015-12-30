Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 644D86B025D
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 15:10:13 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id to18so172208412igc.0
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:10:13 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id x1si43873200igl.76.2015.12.30.12.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 12:10:12 -0800 (PST)
Received: by mail-ig0-x234.google.com with SMTP id to18so172208240igc.0
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:10:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151230092337.GD3873@htj.duckdns.org>
References: <20150913185940.GA25369@htj.duckdns.org>
	<55FEC685.5010404@oracle.com>
	<20150921200141.GH13263@mtj.duckdns.org>
	<20151125144354.GB17308@twins.programming.kicks-ass.net>
	<20151125150207.GM11639@twins.programming.kicks-ass.net>
	<CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
	<20151125174449.GD17308@twins.programming.kicks-ass.net>
	<20151211162554.GS30240@mtj.duckdns.org>
	<20151215192245.GK6357@twins.programming.kicks-ass.net>
	<20151230092337.GD3873@htj.duckdns.org>
Date: Wed, 30 Dec 2015 12:10:12 -0800
Message-ID: <CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
Subject: Re: [PATCH v4.4-rc7] sched: isolate task_struct bitfields according
 to synchronization domains
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov@parallels.com>, kernel-team <kernel-team@fb.com>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Dec 30, 2015 at 1:23 AM, Tejun Heo <tj@kernel.org> wrote:
>
> Peter, I took the patch and changed the bitfields to ulong.

I wouldn't expect the unsigned long part to matter, except for the
forced split with

   unsigned long :0;

itself.

Also, quite frankly, since this is basically very close to other
fields that are *not* unsigned longs, I'd really prefer to not
unnecessarily use a 64-bit field for three bits each.

So why not just do it with plain unsigned "int", and then maybe just
intersperse them with the other int-sized fields in that neighborhood.

I'm also wondering if we shouldn't just put the scheduler bits in the
"atomic_flags" thing instead?

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
