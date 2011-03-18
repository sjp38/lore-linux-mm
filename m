Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB658D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:34:57 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2IJGITr032190
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:16:18 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 9C1A86E8036
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:34:54 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2IJYsOc329336
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:34:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2IJYqIi007111
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:34:54 -0400
Date: Sat, 19 Mar 2011 00:58:11 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 16/20] 16: uprobes: register a
 notifier for uprobes.
Message-ID: <20110318192811.GE31152@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133708.27435.81257.sendpatchset@localhost6.localdomain6>
 <20110315195636.GB24972@fibrous.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110315195636.GB24972@fibrous.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Stephen Wilson <wilsons@start.ca> [2011-03-15 15:56:36]:

> On Mon, Mar 14, 2011 at 07:07:08PM +0530, Srikar Dronamraju wrote:
> > +static int __init init_uprobes(void)
> > +{
> > +	register_die_notifier(&uprobes_exception_nb);
> > +	return 0;
> > +}
> > +
> 
> Although not currently needed, perhaps it would be best to return the
> result of register_die_notifier() ? 
> 

Okay, I can do that but notifier_chain_register() that gets called from
register_die_notifier() always return 0.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
