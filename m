Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 47BAF6B00B9
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:49:13 -0500 (EST)
Subject: Re: [PATCH v7 3.2-rc2 5/30] uprobes: copy of the original
 instruction.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <1322073616.14799.96.camel@twins>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110733.10512.11835.sendpatchset@srdronam.in.ibm.com>
	 <1322073616.14799.96.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Nov 2011 14:49:08 -0500
Message-ID: <1322077748.20742.68.camel@frodo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Wed, 2011-11-23 at 19:40 +0100, Peter Zijlstra wrote:
> On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > +               /* TODO : Analysis and verification of instruction */
> 
> As in refuse to set a breakpoint on an instruction we can't deal with?
> 
> Do we care? The worst case we'll crash the program, but if we're allowed
> setting uprobes we already have enough privileges to do that anyway,
> right?

Well, I wouldn't be happy if I was running a server, and needed to
analyze something it was doing, and because I screwed up the location of
my probe, I crash the server, made lots of people unhappy and lose my
job over it.

I think we do care, but it can be a TODO item.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
