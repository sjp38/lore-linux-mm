Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id CA03D6B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 01:57:42 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 12 Mar 2012 01:57:41 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AE2176E804C
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 01:57:38 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2C5vc8l195008
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 01:57:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2C5vZpJ021350
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 02:57:38 -0300
Date: Mon, 12 Mar 2012 11:24:37 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/7] uprobes/core: make macro names consistent.
Message-ID: <20120312055437.GH13284@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120310174501.19949.50137.sendpatchset@srdronam.in.ibm.com>
 <20120311140735.GA27053@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120311140735.GA27053@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>

* Ingo Molnar <mingo@elte.hu> [2012-03-11 15:07:36]:

> 
> Which tree are these patches against? They don't apply to 
> tip:master cleanly.

To me it applied cleanly on top of 
commit 90549600c550ab189c4611060603f7f15bda2b5e
Merge: f14da8d 708adc5
Author: Ingo Molnar <mingo@elte.hu>
Date:   Thu Mar 8 12:26:01 2012 +0100

	Merge branch 'tools/kvm'



> 
> Also, for patch titles please use the same capitalization style 
> as you see in the commits I've already applied.
> 

Okay.
Will resend the patchset on top of tip/master 81549e96cec66b0eb5efac58df9e503290dad5c1 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
