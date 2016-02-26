Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C3A046B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 10:43:07 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so77544405wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 07:43:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si16598851wjq.40.2016.02.26.07.43.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 07:43:06 -0800 (PST)
Date: Fri, 26 Feb 2016 16:43:06 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 10/20] kthread: Better support freezable kthread
 workers
Message-ID: <20160226154305.GJ3305@pathway.suse.cz>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
 <1456153030-12400-11-git-send-email-pmladek@suse.com>
 <20160225130115.GJ6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225130115.GJ6357@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 2016-02-25 14:01:15, Peter Zijlstra wrote:
> On Mon, Feb 22, 2016 at 03:57:00PM +0100, Petr Mladek wrote:
> > +enum {
> > +	KTW_FREEZABLE		= 1 << 2,	/* freeze during suspend */
> > +};
> 
> Weird value; what was wrong with 1 << 0 ?

Heh, the flag was inspired by

	WQ_FREEZABLE		= 1 << 2, /* freeze during suspend */

from include/linux/workqueue.h. But it does not really matter.
I could change it to 1 << 0 if it makes people less curious.

Thanks a lot for review,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
