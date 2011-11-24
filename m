Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 39BD26B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 08:14:27 -0500 (EST)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 24 Nov 2011 08:14:24 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAODDRxu2130044
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 08:13:27 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAODDP7f000642
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 11:13:27 -0200
Date: Thu, 24 Nov 2011 18:42:25 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 20/30] tracing: Extract out common code for
 kprobes/uprobes traceevents.
Message-ID: <20111124131225.GE28065@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118111039.10512.78989.sendpatchset@srdronam.in.ibm.com>
 <1322076721.20742.66.camel@frodo>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322076721.20742.66.camel@frodo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

> > + *
> > + * Copyright (C) IBM Corporation, 2010
> > + * Author:     Srikar Dronamraju
> > + *
> > + * Derived from kernel/trace/trace_kprobe.c written by
> 
> Shouldn't the above be:
> 
>  include/linux/trace_kprobe.h ?
> 
> Although, I would think both of these files are a bit more that derived
> from. I would have been a bit stronger on the wording and say: This code
> was copied from trace_kprobe.[ch] written by Masami ...
> 
> Then say,
> 
> Updates to make this generic:
> 
>  * Copyright (C) IBM Corporation, 2010
>  * Author:     Srikar Dronamraju
> 
> -- Steve
> 

Okay, Will do as suggested.
Thanks for reporting/suggesting.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
