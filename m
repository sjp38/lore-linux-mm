Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id B7B2C6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 13:02:01 -0400 (EDT)
Received: by iggf3 with SMTP id f3so37084695igg.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 10:02:01 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id pk1si12286411igb.69.2015.08.05.10.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 10:02:00 -0700 (PDT)
Date: Wed, 5 Aug 2015 12:01:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
In-Reply-To: <20150805163609.GE25159@twins.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.11.1508051201280.29823@east.gentwo.org>
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net> <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
 <20150805163609.GE25159@twins.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ron Murray <rjmx@rjmx.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On Wed, 5 Aug 2015, Peter Zijlstra wrote:

> On Wed, Aug 05, 2015 at 11:32:31AM -0500, Christoph Lameter wrote:
> > On Wed, 5 Aug 2015, Peter Zijlstra wrote:
> >
> > > I'll go have a look; but the obvious question is, what's the last known
> > > good kernel?
> >
> > 4.0.9 according to the original report.
>
> Weird, there have been no changes to this area in v4.0..v4.1.

Rerunning this with "slub_debug" may reveal additional info. Maybe there
is some data corrupting going on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
