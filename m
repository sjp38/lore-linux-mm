Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id AD6F56B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 06:02:57 -0400 (EDT)
Message-ID: <1337767375.13348.148.camel@gandalf.stny.rr.com>
Subject: Re: [PATCH 3/3] tracing: Provide traceevents interface for uprobes
From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 23 May 2012 06:02:55 -0400
In-Reply-To: <20120523095738.GA15587@linux.vnet.ibm.com>
References: <20120403010442.17852.9888.sendpatchset@srdronam.in.ibm.com>
	 <20120403010502.17852.58528.sendpatchset@srdronam.in.ibm.com>
	 <1337764783.13348.142.camel@gandalf.stny.rr.com>
	 <20120523095738.GA15587@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Wed, 2012-05-23 at 15:27 +0530, Srikar Dronamraju wrote:

> Masami already acked the patches and its now part of the -tip tree.
> 
> and these patches got picked into -tip  on May 7 
> 
> f3f096c tracing: Provide trace events interface for uprobes
> 8ab83f5 tracing: Extract out common code for kprobes/uprobes trace events
> 3a6b766 tracing: Modify is_delete, is_return from int to bool

Yeah, I noticed shortly after I replied. I currently can't sleep (been
up since 3:30am EDT), and have been cleaning out my Inbox. I got
confused when I saw these patches marked as "todo" in my folder.

-- Steve



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
