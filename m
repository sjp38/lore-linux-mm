Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76BEC6B0297
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 23:14:27 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 70so55925917ita.22
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 20:14:27 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l126si17389135pga.13.2017.04.23.20.14.26
        for <linux-mm@kvack.org>;
        Sun, 23 Apr 2017 20:14:26 -0700 (PDT)
Date: Mon, 24 Apr 2017 12:13:16 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170424031316.GH21430@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419172019.rohvxmtdalas6g57@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170419172019.rohvxmtdalas6g57@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Apr 19, 2017 at 07:20:19PM +0200, Peter Zijlstra wrote:
> On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> > +config LOCKDEP_CROSSRELEASE
> > +	bool "Lock debugging: make lockdep work for crosslocks"
> > +	select PROVE_LOCKING
> 
> 	depends PROVE_LOCKING
> 
> instead ?

OK. I will change it.

> 
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
> > -- 
> > 1.9.1
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
