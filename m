Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA69C6B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 10:18:34 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so19613501wmp.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 07:18:34 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id vx5si22034381wjc.219.2016.02.27.07.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Feb 2016 07:18:33 -0800 (PST)
Date: Sat, 27 Feb 2016 16:18:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 04/20] kthread: Add drain_kthread_worker()
Message-ID: <20160227151832.GG6356@twins.programming.kicks-ass.net>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
 <1456153030-12400-5-git-send-email-pmladek@suse.com>
 <20160225123551.GG6357@twins.programming.kicks-ass.net>
 <20160226152309.GH3305@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160226152309.GH3305@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Feb 26, 2016 at 04:23:09PM +0100, Petr Mladek wrote:
> I do not have a strong opinion here. On one hand, such a check might
> help with debugging. On the other hand, workqueues have happily lived
> without it for years.

TJ and me have a different view on these things. I'm always for the
strictest possible semantics with strong validation. TJ always worries a
lot about existing users.

Luckily, you don't have users yet :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
