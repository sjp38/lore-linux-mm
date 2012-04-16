Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 054AD6B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 05:28:56 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 03:28:56 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 02037C90057
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 05:28:53 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3G9Ss8G2965748
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 05:28:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3G9SpVA002314
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 05:28:53 -0400
Date: Mon, 16 Apr 2012 14:50:54 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [Updated PATCH 3/3] tracing: Provide trace events interface
 for uprobes
Message-ID: <20120416092054.GC13363@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120413112941.16602.69097.sendpatchset@srdronam.in.ibm.com>
 <4F8902BF.6070801@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4F8902BF.6070801@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

> >  
> >  config UPROBES
> >  	bool "Transparent user-space probes (EXPERIMENTAL)"
> > -	depends on ARCH_SUPPORTS_UPROBES && PERF_EVENTS
> > +	depends on UPROBE_EVENTS && PERF_EVENTS
> 
> Is it UPROBE_EVENTS or UPROBE_EVENT?

Yes, I corrected it in the version that I sent out just now. 
Thanks for pointing this out.


-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
