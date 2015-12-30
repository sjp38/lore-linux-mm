Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id B20C66B0263
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 15:43:48 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id 1so34123677ion.1
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:43:48 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id k82si2119713iof.133.2015.12.30.12.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Dec 2015 12:43:48 -0800 (PST)
Received: by mail-ig0-x235.google.com with SMTP id ik10so31811853igb.1
        for <linux-mm@kvack.org>; Wed, 30 Dec 2015 12:43:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151230204140.GA17398@htj.duckdns.org>
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
	<20151230204140.GA17398@htj.duckdns.org>
Date: Wed, 30 Dec 2015 12:43:48 -0800
Message-ID: <CA+55aFx5awBuuroUXt363w9WXn+TvqfoeKu6VYALu_BONQKb3w@mail.gmail.com>
Subject: Re: [PATCH v4.4-rc7] sched: isolate task_struct bitfields according
 to synchronization domains
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov@parallels.com>, kernel-team <kernel-team@fb.com>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Dec 30, 2015 at 12:41 PM, Tejun Heo <tj@kernel.org> wrote:
>
> Right, I was thinking alpha was doing rmw's for things smaller than
> 64bit.  That's 32bit, not 64.

Right. Alpha has trouble only with 8-bit and 16-bit fields. 32-bit
fields should be "atomic" on all architectures, modulo compiler bugs
(and we've had those).

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
