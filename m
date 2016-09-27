Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 136C86B02A8
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:51:33 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so10612744wmg.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:51:33 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id r4si2231604wmd.5.2016.09.27.07.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 07:51:31 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id l132so1542585wmf.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:51:31 -0700 (PDT)
Date: Tue, 27 Sep 2016 16:51:29 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v15 04/13] task_isolation: add initial support
Message-ID: <20160927145128.GF6242@lerouge>
References: <a321c8a7-fa9c-21f7-61f8-54a8f80763fe@mellanox.com>
 <CALCETrWyKExm9Od3VJ2P9xbL23NPKScgxdQ4R1v5QdNuNXKjmA@mail.gmail.com>
 <e659a498-d951-7d9f-dc0c-9734be3fd826@mellanox.com>
 <CALCETrXA38kv_PEd65j8RHvJKkW5mMxXEmYSr5mec1h3X1hj1w@mail.gmail.com>
 <d15b35ce-5c5d-c451-e47e-d2f915bf70f3@mellanox.com>
 <CALCETrX80akvpLNRQfJsDV560npSa33hSsUB5OYkAtnAn8R7Dg@mail.gmail.com>
 <3f84f736-ed7f-adff-d5f0-4f7db664208f@mellanox.com>
 <CALCETrXrsZjMjdd1jACbrz8GMXQC5FmF8BbkHobmMCbG5GPN7w@mail.gmail.com>
 <20160927142219.GC6242@lerouge>
 <20160927143926.GQ2794@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927143926.GQ2794@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Gilad Ben Yossef <giladb@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Viresh Kumar <viresh.kumar@linaro.org>, Linux API <linux-api@vger.kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Will Deacon <will.deacon@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>

On Tue, Sep 27, 2016 at 04:39:26PM +0200, Peter Zijlstra wrote:
> On Tue, Sep 27, 2016 at 04:22:20PM +0200, Frederic Weisbecker wrote:
> 
> > The RCU context tracking doesn't take care of callbacks. It's only there
> > to tell the RCU core whether the CPU runs code that may or may not run
> > RCU read side critical sections. This is assumed by "kernel may use RCU,
> > userspace can't".
> 
> Userspace never can use the kernels RCU in any case. What you mean to
> say is that userspace is treated like an idle CPU in that the CPU will
> no longer be part of the RCU quescent state machine.
> 
> The transition to userspace (as per context tracking) must ensure that
> CPUs RCU state is 'complete', just like our transition to idle (mostly)
> does.

Exactly!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
