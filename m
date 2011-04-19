Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 871388D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 09:12:25 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 15/26] 15: uprobes: Handing int3 and
 singlestep exception.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <1303218185.8345.0.camel@twins>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143527.15455.32854.sendpatchset@localhost6.localdomain6>
	 <1303218185.8345.0.camel@twins>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 19 Apr 2011 09:12:21 -0400
Message-ID: <1303218742.7181.96.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-04-19 at 15:03 +0200, Peter Zijlstra wrote:
> On Fri, 2011-04-01 at 20:05 +0530, Srikar Dronamraju wrote:
> > +       if (unlikely(!utask)) {
> > +               utask = add_utask();
> > +
> > +               /* Failed to allocate utask for the current task. */
> > +               BUG_ON(!utask);
> 
> That's not really nice is it ;-) means I can make the kernel go BUG by
> simply applying memory pressure.

Agreed,

None of these patches should have a single BUG_ON(). They all must fail
nicely.

-- Steve

> 
> > +               utask->state = UTASK_BP_HIT;
> > +       } 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
