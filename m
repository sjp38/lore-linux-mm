Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5356B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 05:32:33 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 29 Nov 2011 03:32:32 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pATAWRiO148668
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 03:32:27 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pATAWPIe014603
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 03:32:26 -0700
Date: Tue, 29 Nov 2011 16:00:40 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 0/5] uprobes: kill xol vma
Message-ID: <20111129103040.GF13445@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111128190614.GA4602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111128190614.GA4602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

> 
> On top of this series, not for inclusion yet, just to explain what
> I mean. May be someone can test it ;)
> 
> This series kills xol_vma. Instead we use the per_cpu-like xol slots.
> 
> This is much more simple and efficient. And this of course solves
> many problems we currently have with xol_vma.
> 
> For example, we simply can not trust it. We do not know what actually
> we are going to execute in UTASK_SSTEP mode. An application can unmap
> this area and then do mmap(PROT_EXEC|PROT_WRITE, MAP_FIXED) to fool
> uprobes.
> 
> The only disadvantage is that this adds a bit more arch-dependant
> code.
> 
> The main question, can this work? I know very little in this area.
> And I am not sure if this can be ported to other architectures.

Nice idea. I think this will help us in implementing boosted uprobes if
tweak a bit.  (i.e having a jump after the actual instruction that gets
us back to the actual instruction stream). The current method of using a
first cum-first-serve slot reservation doesnt work for booster because
we have had to clear the slot in the post processing. 

I will apply your patches and test and let you know how it goes. (in a day
or two).

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
