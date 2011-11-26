Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D77396B002D
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 21:24:14 -0500 (EST)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 25 Nov 2011 21:24:13 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAQ2OAXL442914
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 21:24:10 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAQ2O9JC016611
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 21:24:10 -0500
Date: Sat, 26 Nov 2011 07:52:57 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 12/30] uprobes: Handle breakpoint and
 Singlestep
Message-ID: <20111126022257.GA3291@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110903.10512.88532.sendpatchset@srdronam.in.ibm.com>
 <1322234662.2535.8.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322234662.2535.8.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

* Peter Zijlstra <peterz@infradead.org> [2011-11-25 16:24:22]:

> On Fri, 2011-11-18 at 16:39 +0530, Srikar Dronamraju wrote:
> 
> > +       consumer = uprobe->consumers;
> > +       for (consumer = uprobe->consumers; consumer;
> > +                                       consumer = consumer->next) { 
> 
> that first expression seems redundant..

Yes,  will remove.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
