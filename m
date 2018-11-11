Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF65E6B0006
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 20:30:21 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c15-v6so4211342pls.15
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 17:30:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e1-v6si9705637pfe.44.2018.11.10.17.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Nov 2018 17:30:20 -0800 (PST)
Date: Sun, 11 Nov 2018 02:30:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 07/12] locking/lockdep: Add support for nested
 terminal locks
Message-ID: <20181111013017.GC12766@worktop.psav.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-8-git-send-email-longman@redhat.com>
 <20181110142023.GG3339@worktop.programming.kicks-ass.net>
 <f3fc6819-175b-6452-4705-942a82d7e06f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3fc6819-175b-6452-4705-942a82d7e06f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Nov 10, 2018 at 07:30:54PM -0500, Waiman Long wrote:
> On 11/10/2018 09:20 AM, Peter Zijlstra wrote:
> > On Thu, Nov 08, 2018 at 03:34:23PM -0500, Waiman Long wrote:
> >> There are use cases where we want to allow 2-level nesting of one
> >> terminal lock underneath another one. So the terminal lock type is now
> >> extended to support a new nested terminal lock where it can allow the
> >> acquisition of another regular terminal lock underneath it.
> > You're stretching things here... If you're allowing things under it, it
> > is no longer a terminal lock.
> >
> > Why would you want to do such a thing?
> 
> A majority of the gain in debugobjects is to make the hash lock a kind
> of terminal lock. Yes, I may be stretching it a bit here. I will take
> back the nesting patch and consider doing that in a future patch.

Maybe try and write a better changelog? I'm not following, but that
could also be because I've been awake for almost 20 hours :/
