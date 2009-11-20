Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EA0FE6B0095
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:31:01 -0500 (EST)
Date: Fri, 20 Nov 2009 09:30:53 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
Message-ID: <20091120083053.GB19778@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
 <20091120081440.GA19778@elte.hu>
 <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> On Fri, Nov 20, 2009 at 10:14 AM, Ingo Molnar <mingo@elte.hu> wrote:
> > Pekka, Eduard and the other slab hackers might have ideas about what
> > other stats they generally like to see to judge the health of a workload
> > (or system).
> 
> kmalloc()/kfree() CPU ping-pong call-sites (i.e. alloc and free
> happening on different CPUs) is one interesting metric we haven't
> implemented yet. Valgrind massif tool type of output graph would be
> helpful as well:
> 
> http://valgrind.org/docs/manual/ms-manual.html
> 
> On Fri, Nov 20, 2009 at 10:14 AM, Ingo Molnar <mingo@elte.hu> wrote:
> > If this iteration looks good to the slab folks then i can apply it as-is
> > and we can do the other changes relative to that. It looks good to me as
> > a first step, and it's functional already.
> 
> Yeah, looks OK to me as the first step. Patch 2 looks premature,
> though, looking at the output of "perf kmem" from patch 1.
> 
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

Great - thanks for the quick ack!

Regarding patch 2 - can we set some definitive benchmark threshold for 
that? I.e. a list of must-have features in 'perf kmem' before we can do 
it? 100% information and analysis equivalency with kmemtrace-user tool? 
Eduard, what do you think?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
