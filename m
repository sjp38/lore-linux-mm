Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id B66E56B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:30:45 -0400 (EDT)
Received: by ykoo7 with SMTP id o7so54217924yko.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:30:45 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id m67si4144694ywc.351.2015.10.14.10.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 10:30:44 -0700 (PDT)
Received: by ykey125 with SMTP id y125so54167203yke.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:30:44 -0700 (PDT)
Date: Wed, 14 Oct 2015 13:30:39 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20151014173039.GB12799@mtj.duckdns.org>
References: <20150922193513.GE17659@mtj.duckdns.org>
 <20150925112617.GA3122@pathway.suse.cz>
 <20150928170314.GF2589@mtj.duckdns.org>
 <20151002154336.GC3122@pathway.suse.cz>
 <20151002192453.GA7564@mtj.duckdns.org>
 <20151005100758.GK9603@pathway.suse.cz>
 <20151005110924.GL9603@pathway.suse.cz>
 <20151007092130.GD3122@pathway.suse.cz>
 <20151007142446.GA2012@mtj.duckdns.org>
 <20151014102022.GA2880@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151014102022.GA2880@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Oct 14, 2015 at 12:20:22PM +0200, Petr Mladek wrote:
> IMHO, it would be great if it is easy to convert between the
> kthread worker and workqueues API. It will allow to choose

Sure, keep the APIs similar so that they can be easily converted back
and forth but that doesn't mean kthread_worker should be as complex as
workqueue.  Workqueue is *really* complex partly for historical
reasons and partly because it has to serve all corner cases.  Please
make something simple which is similar enough to enable easy miration.
That amount of complexity simply isn't necessary for kthread_worker.

...
> PS: I am not convinced that all my concerns were non-issues.
> For example, I agree that a race when queuing the same work
> to more kthread workers might look theoretical. On the other
> hand, the API allows it and it might be hard to debug. IMHO,

There are big differences in terms of complexity between ensuring
something like the above working correctly under all circumstances and
implementing a warning trap which would trigger well enough to warn
against unsupported usages.  These are active trade-offs to make and
not particularly hard ones either.  Let's please keep kthread_worker
simple.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
