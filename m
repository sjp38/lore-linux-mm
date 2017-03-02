Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C28B36B038B
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 18:43:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 65so109125659pgi.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 15:43:50 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d67si8754044pfe.39.2017.03.02.15.43.49
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 15:43:49 -0800 (PST)
Date: Fri, 3 Mar 2017 08:43:32 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170302234331.GD28562@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170302134103.GS6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302134103.GS6515@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Mar 02, 2017 at 02:41:03PM +0100, Peter Zijlstra wrote:
> On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> > diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> > index a6c8db1..7890661 100644
> > --- a/lib/Kconfig.debug
> > +++ b/lib/Kconfig.debug
> > @@ -1042,6 +1042,19 @@ config DEBUG_LOCK_ALLOC
> >  	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
> >  	 held during task exit.
> >  
> > +config LOCKDEP_CROSSRELEASE
> > +	bool "Lock debugging: make lockdep work for crosslocks"
> > +	select LOCKDEP
> > +	select TRACE_IRQFLAGS
> > +	default n
> > +	help
> > +	 This makes lockdep work for crosslock which is a lock allowed to
> > +	 be released in a different context from the acquisition context.
> > +	 Normally a lock must be released in the context acquiring the lock.
> > +	 However, relexing this constraint helps synchronization primitives
> > +	 such as page locks or completions can use the lock correctness
> > +	 detector, lockdep.
> > +
> >  config PROVE_LOCKING
> >  	bool "Lock debugging: prove locking correctness"
> >  	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT
> 
> 
> Does CROSSRELEASE && !PROVE_LOCKING make any sense?

No, it does not make sense. I will fix it. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
