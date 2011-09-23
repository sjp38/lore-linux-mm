Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1E39000BD
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 04:14:59 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p8P8Emww021184
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 08:14:48 GMT
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8P8EkfI2723872
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 09:14:48 +0100
Received: from d06av10.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8P8Ej4S013590
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 02:14:46 -0600
Date: Fri, 23 Sep 2011 17:51:32 +0100
From: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 8/26]   x86: analyze instruction and
 determine fixups.
Message-ID: <20110923165132.GA23870@stefanha-thinkpad.localdomain>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com>
 <20110920171310.GC27959@stefanha-thinkpad.localdomain>
 <20110920181225.GA5149@infradead.org>
 <20110920205317.GA1508@stefanha-thinkpad.localdomain>
 <4E7C7353.50802@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E7C7353.50802@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 23, 2011 at 08:53:55PM +0900, Masami Hiramatsu wrote:
> (2011/09/21 5:53), Stefan Hajnoczi wrote:
> > On Tue, Sep 20, 2011 at 02:12:25PM -0400, Christoph Hellwig wrote:
> >> On Tue, Sep 20, 2011 at 06:13:10PM +0100, Stefan Hajnoczi wrote:
> > But this should be solvable so it would be possible to use perf-probe(1)
> > on a std.h-enabled binary.  Some distros already ship such binaries!
> 
> I'm not sure that we should stick on the current implementation
> of the sdt.h. I think we'd better modify the sdt.h to replace
> such semaphores with checking whether the tracepoint is changed from nop.

I like this option.  The only implication is that all userspace tracing
needs to go through uprobes if we want to support multiple consumers
tracing the same address.

> Or, we can introduce an add-hoc ptrace code to perftools for modifying
> those semaphores. However, this means that user always has to use
> perf to trace applications, and it's hard to trace multiple applications
> at a time (can we attach all of them?)...

I don't think perf needs to stay attached to the processes.  It just
needs to increment the semaphores on startup and decrement them on
shutdown.

Are you going to attempt either of these implementations?

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
