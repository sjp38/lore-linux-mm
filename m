Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 120FE6B0761
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 17:43:24 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id j6-v6so5387609wre.1
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 14:43:24 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z9-v6si9290214wrh.223.2018.11.10.14.43.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 10 Nov 2018 14:43:22 -0800 (PST)
Date: Sat, 10 Nov 2018 15:10:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
Message-ID: <20181110141045.GD3339@worktop.programming.kicks-ass.net>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <20181109080412.GC86700@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109080412.GC86700@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Waiman Long <longman@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Nov 09, 2018 at 09:04:12AM +0100, Ingo Molnar wrote:
> BTW., if you are interested in more radical approaches to optimize 
> lockdep, we could also add a static checker via objtool driven call graph 
> analysis, and mark those locks terminal that we can prove are terminal.
> 
> This would require the unified call graph of the kernel image and of all 
> modules to be examined in a final pass, but that's within the principal 
> scope of objtool. (This 'final pass' could also be done during bootup, at 
> least in initial versions.)

Something like this is needed for objtool LTO support as well. I just
dread the build time 'regressions' this will introduce :/

The final link pass is already by far the most expensive part (as
measured in wall-time) of building a kernel, adding more work there
would really suck :/
