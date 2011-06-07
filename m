Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE786B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 12:13:12 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p57G1XYq010043
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 12:01:33 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57GD8hk050806
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 12:13:08 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57AD51h013843
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 04:13:07 -0600
Date: Tue, 7 Jun 2011 21:36:12 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 20/22] 20: perf: perf interface for
 uprobes
Message-ID: <20110607160612.GB8876@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607130216.28590.5724.sendpatchset@localhost6.localdomain6>
 <20110607133039.GA4929@infradead.org>
 <20110607133853.GC9949@in.ibm.com>
 <20110607142116.GA8311@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110607142116.GA8311@ghostprotocols.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

* Arnaldo Carvalho de Melo <acme@infradead.org> [2011-06-07 11:21:16]:

> Em Tue, Jun 07, 2011 at 07:08:53PM +0530, Ananth N Mavinakayanahalli escreveu:
> > On Tue, Jun 07, 2011 at 09:30:39AM -0400, Christoph Hellwig wrote:
> > > On Tue, Jun 07, 2011 at 06:32:16PM +0530, Srikar Dronamraju wrote:
> > > > Enhances perf probe to user space executables and libraries.
> > > > Provides very basic support for uprobes.
> 
> > > Nice.  Does this require full debug info for symbolic probes,
> > > or can it also work with simple symbolc information?
> 
> > It works only with symbol information for now.
> > It doesn't (yet) know how to use debuginfo :-)
> 
> 'perf probe' uses perf symbol library, so it really don't have to know
> from where symbol resolution information is obtained, only if it needs
> things that are _just_ on debuginfo, such as line information, etc.
> 
> But then that is also already supported in 'perf probe'.
> 
> Or is there something else in particular you're thinking?
> 

What Ananth was saying was that perf probe for uprobes still has to take
advantage of tracing using line number; Also it is still restricted to
showing only register contents and we still have to add support for variables. I know that perf symbol library has support for that
just that we have to enable it for uprobes.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
