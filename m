Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id C60D26B025F
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 15:17:48 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id mw1so56294356igb.1
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:17:48 -0800 (PST)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id 83si6708641iob.197.2015.12.30.12.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 12:17:48 -0800 (PST)
Received: by mail-io0-x232.google.com with SMTP id o67so359454110iof.3
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:17:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
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
	<CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
Date: Wed, 30 Dec 2015 12:17:48 -0800
Message-ID: <CA+55aFxFBKx5qo67qDcBdeH3pk6sjVAi-iAtYO7bgpoyJM4Fyw@mail.gmail.com>
Subject: Re: [PATCH v4.4-rc7] sched: isolate task_struct bitfields according
 to synchronization domains
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov@parallels.com>, kernel-team <kernel-team@fb.com>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Dec 30, 2015 at 12:10 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Also, quite frankly, since this is basically very close to other
> fields that are *not* unsigned longs, I'd really prefer to not
> unnecessarily use a 64-bit field for three bits each.

Side note: I don't hate the patch. I think it's a good catch, and
would take it as-is. I just think it could be better.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
