Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0030C6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 08:44:56 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id a85so237958883ykb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 05:44:55 -0800 (PST)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id 193si43200280ywe.18.2016.01.06.05.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 05:44:55 -0800 (PST)
Received: by mail-yk0-x233.google.com with SMTP id a85so237958545ykb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 05:44:55 -0800 (PST)
Date: Wed, 6 Jan 2016 08:44:53 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4.4-rc7] sched: move sched lock synchronized bitfields
 in task_struct into ->atomic_flags
Message-ID: <20160106134453.GB29797@mtj.duckdns.org>
References: <20150921200141.GH13263@mtj.duckdns.org>
 <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net>
 <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
 <20151125174449.GD17308@twins.programming.kicks-ass.net>
 <20151211162554.GS30240@mtj.duckdns.org>
 <20151215192245.GK6357@twins.programming.kicks-ass.net>
 <20151230092337.GD3873@htj.duckdns.org>
 <CA+55aFx0WxoUPrOPaq3HxM+YUQQ0DPV-c3f8kE1ec7agERb_Lg@mail.gmail.com>
 <20160101025628.GA3660@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160101025628.GA3660@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vladimir Davydov <vdavydov@parallels.com>, kernel-team <kernel-team@fb.com>, Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Dec 31, 2015 at 09:56:28PM -0500, Tejun Heo wrote:
> task_struct has a cluster of unsigned bitfields.  Some are updated
> under scheduler locks while others are updated only by the task
> itself.  Currently, the two classes of bitfields aren't distinguished
> and end up on the same word which can lead to clobbering when there
> are simultaneous read-modify-write attempts.  While difficult to prove
> definitely, it's likely that the resulting inconsistency led to low
> frqeuency failures such as wrong memcg_may_oom state or loadavg
> underflow due to clobbered sched_contributes_to_load.

Ping.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
