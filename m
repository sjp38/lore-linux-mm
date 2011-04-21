Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 725298D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:34:43 -0400 (EDT)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1QCs9j-0001d7-2M
	for linux-mm@kvack.org; Thu, 21 Apr 2011 11:34:43 +0000
Subject: Re: [PATCH v3 2.6.39-rc1-tip 18/26] 18: uprobes: commonly used
 filters.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110421110911.GE10698@linux.vnet.ibm.com>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143602.15455.82211.sendpatchset@localhost6.localdomain6>
	 <1303221477.8345.6.camel@twins> <20110421110911.GE10698@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 13:37:15 +0200
Message-ID: <1303385835.2035.75.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 2011-04-21 at 16:39 +0530, Srikar Dronamraju wrote:
> > What you want is to save the pid-namespace of the task creating the
> > filter in your uprobe_simple_consumer and use that to obtain the task's
> > pid for matching with the provided number.
> > 
> 
> Okay, will do by adding the pid-namespace of the task creating the
> filter in the uprobe_simple_consumer. 

Maybe you could convert to the global pid namespace on construction and
always use that for comparison.

That would avoid the namespace muck on comparison.. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
