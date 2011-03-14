Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 601048D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:34:59 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2EHE3t7003238
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:14:04 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2E0E46E8041
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:34:57 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EHYvgV161194
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:34:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EHYsAE011947
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:34:56 -0300
Date: Mon, 14 Mar 2011 22:59:08 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 1/20]  1: mm: Move replace_page() to
 mm/memory.c
Message-ID: <20110314172908.GP24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133413.27435.67467.sendpatchset@localhost6.localdomain6>
 <1300112195.9910.92.camel@gandalf.stny.rr.com>
 <20110314170227.GN24254@linux.vnet.ibm.com>
 <1300122834.9910.126.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300122834.9910.126.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

> > 
> > As discussed in IRC, moving and removing the static attribute had to
> > be one patch so that mm/ksm.c compiles correctly. The other option we
> > have is to remove the static attribute first and then moving the
> > function.
> 
> Hmm, maybe that may be a good idea. Since it is really two changes. One
> is to make it global for other usages. I'm not even sure why you moved
> it. The change log for the move can explain that.
> 

unlike mm/memory.c; mm/ksm.c is compiled only when CONFIG_KSM is set.
So if we dont move it out of ksm.c; we will have to make uprobes
dependent on CONFIG_KSM. Since replace_page is the only function we are
interested in, its better to move it out of ksm.c, rather than
making uprobes dependent on CONFIG_KSM.


> -- Steve
> 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
