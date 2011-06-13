Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4AEB26B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:31:15 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5D99jBB002638
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:09:45 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5D9VD7C085988
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:31:13 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5D9VAgL010849
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 06:31:13 -0300
Date: Mon, 13 Jun 2011 14:53:39 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 0/22]  0: Uprobes patchset with perf
 probe support
Message-ID: <20110613092339.GF27130@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <1307644944.2497.1023.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1307644944.2497.1023.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-09 20:42:24]:

> On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> > - Breakpoint handling should co-exist with singlestep/blockstep from
> >   another tracer/debugger.

We can remove this now.
Previous to this patchset the post notifier would run in interrupt
context hence we couldnt call user_disable_single_step

However from this patchset, (due to changes to do away with per task
slot), we run the post notifier in task context. Hence we can now call
user_enable_single_step/user_disable_single_step which does the right
thing. 

Please correct me if I am missing.

> > - Queue and dequeue signals delivered from the singlestep till
> >   completion of postprocessing. 
> 

I am working towards this.  
> These two are important to sort before we can think of merging this
> right?
> 

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
