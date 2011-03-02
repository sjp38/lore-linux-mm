Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6B218D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 13:50:07 -0500 (EST)
Date: Wed, 2 Mar 2011 19:49:53 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
Message-ID: <20110302184953.GH13693@elte.hu>
References: <no>
 <1299055090-23976-4-git-send-email-namei.unix@gmail.com>
 <20110302084542.GA20795@elte.hu>
 <1299085326.8493.820.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299085326.8493.820.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Liu Yuan <namei.unix@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>


* Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Wed, 2011-03-02 at 09:45 +0100, Ingo Molnar wrote:
> > But, instead of trying to improve those aspects of our existing instrumentation 
> > frameworks, mm/* is gradually growing its own special instrumentation hacks, missing 
> > the big picture and fragmenting the instrumentation space some more.
> > 
> > That trend is somewhat sad. 
> 
> Go any handy examples of how you'd like to see these done?

There's a very, very old branch in tip:tracing/mm (by Steve) that shows off some of 
the concepts that could be introduced, to 'dump' current MM state via an extension 
to the tracepoints APIs:

3383e37ea796: tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
c33b3596bc38: tracing, page-allocator: Add trace event for page traffic related to the buddy lists
0d524fb734bc: tracing, mm: Add trace events for anti-fragmentation falling back to other migratetypes
b9a28177eedf: tracing, page-allocator: Add trace events for page allocation and page freeing
807243eb20b2: Merge branch 'perfcounters/urgent' into tracing/mm
08b6cb88eeb5: perf_counter tools: Provide default bfd_demangle() function in case it's not around
eb4671011887: tracing/mm: rename 'trigger' file to 'dump_range'
1487a7a1ff99: tracing/mm: fix mapcount trace record field
dcac8cdac1d4: tracing/mm: add page frame snapshot trace

That's just a demo in essence - showing what things could be done in this area.

You can pick those commits up via running:

  http://people.redhat.com/mingo/tip.git/README

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
