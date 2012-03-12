Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 138176B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 02:11:03 -0400 (EDT)
Date: Mon, 12 Mar 2012 07:10:37 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/7] uprobes/core: make macro names consistent.
Message-ID: <20120312061037.GA32408@elte.hu>
References: <20120310174501.19949.50137.sendpatchset@srdronam.in.ibm.com>
 <20120311140735.GA27053@elte.hu>
 <20120312055437.GH13284@linux.vnet.ibm.com>
 <20120312060503.GA1479@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120312060503.GA1479@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>


* Ingo Molnar <mingo@elte.hu> wrote:

> > To me it applied cleanly on top of 
> > commit 90549600c550ab189c4611060603f7f15bda2b5e
> 
> It's a new commit:
> 
>  c94082656dac: x86: Use enum instead of literals for trap values
> 
> Interacting with this cleanup:
> 
>  x86/trivial: Rename trap_no to trap_nr in thread struct

Btw., you can resend just this merged patch instead of resending 
the whole series, as the other bits should still apply cleanly.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
