Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1925D6B004A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 21:14:07 -0400 (EDT)
Date: Fri, 13 Apr 2012 22:13:30 -0300
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH] perf/probe: Provide perf interface for uprobes
Message-ID: <20120414011330.GC31880@infradead.org>
References: <20120411135742.29198.45061.sendpatchset@srdronam.in.ibm.com>
 <20120411144918.GD16257@infradead.org>
 <20120411170343.GB29831@linux.vnet.ibm.com>
 <20120411181727.GK16257@infradead.org>
 <4F864BB3.3090405@hitachi.com>
 <20120412140751.GM16257@infradead.org>
 <20120412151037.GC21587@linux.vnet.ibm.com>
 <4F87C76B.10001@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F87C76B.10001@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

Em Fri, Apr 13, 2012 at 03:27:55PM +0900, Masami Hiramatsu escreveu:
> (2012/04/13 0:10), Srikar Dronamraju wrote:
> >>  $ perf probe libc malloc
> >>
> >> 	Makes it even easier to use.
> >>
> >> 	Its just when one asks for something that has ambiguities that
> >> the tool should ask the user to be a bit more precise to remove such
> >> ambiguity.
> >>
> >> 	After all...

> > Another case 
> > perf probe do_fork clone_flags now looks for variable clone_flags in
> > kernel function do_fork.

> > But if we allow to trace perf probe zsh zfree; then 
> > 'perf probe do_fork clone_flags' should it check for do_fork executable
> > or not? If it does check and finds one, and searches for clone_flags
> > function and doesnt find, then should it continue with searching the
> > kernel?

> Agree. I'd like to suggest you to start with only full path support,
> and see, how we can handle abbreviations :)

Agreed, I was just making usability suggestions.

Those can be implemented later, if we agree they ease the tool use.

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
