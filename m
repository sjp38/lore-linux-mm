Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C80456B00B9
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:50:25 -0500 (EST)
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <1322072149.14799.89.camel@twins>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
	 <1322072149.14799.89.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Nov 2011 14:50:19 -0500
Message-ID: <1322077819.20742.69.camel@frodo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Wed, 2011-11-23 at 19:15 +0100, Peter Zijlstra wrote:
> On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > @@ -545,8 +547,14 @@ again:                     remove_next = 1 + (end > next->vm_end);
> 
> I'm not sure if you use quilt or git to produce these patches but can
> you either add:
> 
> QUILT_DIFF_OPTS="-F ^[[:alpha:]\$_].*[^:]\$"
> 
> to your .quiltrc, or:
> 
> [diff "default"]
>                 xfuncname = "^[[:alpha:]$_].*[^:]$"
> 
> to your .gitconfig ?
> 

or just place a space in front of "again:"

/me runs!

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
