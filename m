Date: Fri, 10 Oct 2008 09:23:34 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: git-slab plus git-tip breaks i386 allnoconfig
Message-ID: <20081010072334.GA15715@elte.hu>
References: <20081009164700.c9042902.akpm@linux-foundation.org> <20081009170349.35e0df12.akpm@linux-foundation.org> <1223621125.8959.9.camel@penberg-laptop> <20081010071815.GA23247@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081010071815.GA23247@Krystal>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

* Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> * Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> > Hi,
> > 
> > On Thu, 2008-10-09 at 17:03 -0700, Andrew Morton wrote:
> > > OK, i386 allmodconfig is suffering something similar.
> > > 
> > > In file included from include/linux/slub_def.h:13,
> > >                  from include/linux/slab.h:184,
> > >                  from include/linux/percpu.h:5,
> > >                  from include/linux/rcupdate.h:39,
> > >                  from include/linux/marker.h:16,
> > >                  from include/linux/module.h:18,
> > >                  from include/linux/crypto.h:21,
> > >                  from arch/x86/kernel/asm-offsets_32.c:7,
> > >                  from arch/x86/kernel/asm-offsets.c:2:
> > > include/linux/kmemtrace.h: In function 'kmemtrace_mark_alloc_node':
> > > include/linux/kmemtrace.h:33: error: implicit declaration of function 'trace_mark'
> > > include/linux/kmemtrace.h:33: error: 'kmemtrace_alloc' undeclared (first use in this function)
> > > include/linux/kmemtrace.h:33: error: (Each undeclared identifier is reported only once
> > > include/linux/kmemtrace.h:33: error: for each function it appears in.)
> > > include/linux/kmemtrace.h: In function 'kmemtrace_mark_free':
> > > include/linux/kmemtrace.h:44: error: 'kmemtrace_free' undeclared (first use in this function)
> > > 
> > > I'll drop the slab tree.
> > 
> > Oh, marker.h includes kmemtrace.h through dependencies... I'd argue
> > that's a marker.h bug; otherwise I don't see how we can use it in slab.
> > Mathieu?
> > 
> > 		Pekka
> > 
> 
> (already sent privately to Ingo and Andrew)
> 
> Ingo, can you simply revert commits
> 44c2a8c1cdf0f3374ef2f4f91db551527a336fb2
> "markers: turn marker_synchronize_unregister() into an inline"
> and
> "Tracepoints synchronize unregister static inline"
> (this last one does not seem to have hit -tip yet, but may be in -ftrace
> staging)
> 
> That should fix the issue.

hm, could you please send a fix instead? I can revert from integration 
branches temporarily but this needs a real fix.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
