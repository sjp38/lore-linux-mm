Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42B6A8308E
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 03:59:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so28973318pfd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 00:59:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c203si43994141pfb.235.2016.08.30.00.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 00:59:57 -0700 (PDT)
Date: Tue, 30 Aug 2016 09:59:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Message-ID: <20160830075949.GA10153@twins.programming.kicks-ass.net>
References: <1471382376-5443-1-git-send-email-cmetcalf@mellanox.com>
 <1471382376-5443-5-git-send-email-cmetcalf@mellanox.com>
 <20160829163352.GV10153@twins.programming.kicks-ass.net>
 <fe4b8667-57d5-7767-657a-d89c8b62f8e3@mellanox.com>
 <20160829164809.GW10153@twins.programming.kicks-ass.net>
 <ccd4a21a-8de5-38f0-5e78-1ad999755b7a@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ccd4a21a-8de5-38f0-5e78-1ad999755b7a@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Aug 29, 2016 at 12:53:30PM -0400, Chris Metcalf wrote:

> Would it be cleaner to just replace the set_tsk_need_resched() call
> with something like:
> 
>     set_current_state(TASK_INTERRUPTIBLE);
>     schedule();
>     __set_current_state(TASK_RUNNING);
> 
> or what would you recommend?

That'll just get you to sleep _forever_...

> Or, as I said, just doing a busy loop here while testing to see
> if need_resched or signal had been set?

Why do you care about need_resched() and or signals? How is that related
to the tick being stopped or not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
