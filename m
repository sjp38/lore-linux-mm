Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 641A26B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 01:57:11 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p5A5kbSN006673
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:16:37 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5A5v2A12965642
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:27:03 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5A5v1uD017703
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:57:02 +1000
Date: Fri, 10 Jun 2011 11:26:48 +0530
From: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 0/22]  0: Uprobes patchset with perf
	probe support
Message-ID: <20110610055648.GA22707@in.ibm.com>
Reply-To: ananth@in.ibm.com
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <1307644944.2497.1023.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307644944.2497.1023.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 09, 2011 at 08:42:24PM +0200, Peter Zijlstra wrote:
> On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> > - Breakpoint handling should co-exist with singlestep/blockstep from
> >   another tracer/debugger.
> > - Queue and dequeue signals delivered from the singlestep till
> >   completion of postprocessing. 
> 
> These two are important to sort before we can think of merging this
> right?

Yup.

Guess Srikar missed updating this part, but the first of the issues
(sstep/blockstep) is now fixed. Signal queueing is a work-in-progress.

Ananth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
