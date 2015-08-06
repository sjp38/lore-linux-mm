Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id C92586B0253
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 23:31:20 -0400 (EDT)
Received: by ioii16 with SMTP id i16so69253237ioi.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 20:31:20 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id m7si556321igk.28.2015.08.05.20.31.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 20:31:19 -0700 (PDT)
Date: Wed, 5 Aug 2015 22:31:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
In-Reply-To: <55C2BC00.8020302@rjmx.net>
Message-ID: <alpine.DEB.2.11.1508052229540.891@east.gentwo.org>
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net> <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org> <20150805163609.GE25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051201280.29823@east.gentwo.org> <55C2BC00.8020302@rjmx.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ron Murray <rjmx@rjmx.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On Wed, 5 Aug 2015, Ron Murray wrote:

> OK, tried that (with no parameters though. Should I try some?). That got
> me a crash with a blank screen and no panic report. The thing is clearly

Hmmm... Crash early on? Could you attach a serial console and try
"earlyprintk" as an option as well?

> touchy: small changes in memory positions make a difference. That's
> probably why I didn't get a panic message until 4.1.4: the gods have to
> all be looking in the right direction.

Subtle corruption issue. If slub_debug does not get it then other
debugging techniques may have to be used.

> > [  OK  ] Stopped CUPS Scheduler.
> > [  OK  ] Stopped (null).
> > ------------[ cut here ]------------
>
> Note the "Stopped (null)" before the "cut here" line. I wonder whether
> that has anything to do with the problem, or is it a red herring?

Hmmm... Thats a message from user space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
