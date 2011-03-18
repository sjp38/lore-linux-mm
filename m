Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4946C8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 18:11:54 -0400 (EDT)
Date: Fri, 18 Mar 2011 18:10:42 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 17/20] 17: uprobes: filter chain
Message-ID: <20110318221042.GA3586@fibrous.localdomain>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133722.27435.55663.sendpatchset@localhost6.localdomain6> <20110315194914.GA24972@fibrous.localdomain> <20110318191648.GD31152@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110318191648.GD31152@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


On Sat, Mar 19, 2011 at 12:46:48AM +0530, Srikar Dronamraju wrote:
> > > +	for (consumer = uprobe->consumers; consumer;
> > > +					consumer = consumer->next) {
> > > +		if (!consumer->filter || consumer->filter(consumer, t)) {
> > 
> > The implementation does not seem to match the changelog description.
> > Should this not be:
> > 
> >                 if (consumer->filter && consumer->filter(consumer, t))
> > 
> >   ?
> 
> filter is optional; if filter is present, then it means that the
> tracer is interested in a specific set of processes that maps this
> inode. If there is no filter; it means that it is interested in all
> processes that map this filter. 

Ah OK.  That does make sense then.  Thanks!


> filter_chain() should return true if any consumer is interested in
> tracing this task.  if there is a consumer who hasnt defined a filter
> then we dont need to loop thro remaining consumers.
> 
> Hence 
> 
> if (!consumer->filter || consumer->filter(consumer, t)) {
>  
> seems better suited to me.

-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
