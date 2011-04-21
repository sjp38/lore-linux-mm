Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B87308D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 08:03:58 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3LBrG3g026349
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:53:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3LC3j6G1749062
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 08:03:45 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3LC3ehh000597
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:03:42 -0300
Date: Thu, 21 Apr 2011 17:19:36 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 18/26] 18: uprobes: commonly used
 filters.
Message-ID: <20110421114936.GF10698@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143602.15455.82211.sendpatchset@localhost6.localdomain6>
 <1303221477.8345.6.camel@twins>
 <20110421110911.GE10698@linux.vnet.ibm.com>
 <1303385835.2035.75.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1303385835.2035.75.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-04-21 13:37:15]:

> On Thu, 2011-04-21 at 16:39 +0530, Srikar Dronamraju wrote:
> > > What you want is to save the pid-namespace of the task creating the
> > > filter in your uprobe_simple_consumer and use that to obtain the task's
> > > pid for matching with the provided number.
> > > 
> > 
> > Okay, will do by adding the pid-namespace of the task creating the
> > filter in the uprobe_simple_consumer. 
> 
> Maybe you could convert to the global pid namespace on construction and
> always use that for comparison.
> 
> That would avoid the namespace muck on comparison.. 
> 

Yeah, this idea also seems feasible.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
