Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 0A01D6B00A8
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 07:28:03 -0500 (EST)
Date: Tue, 17 Jan 2012 13:27:41 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120117122741.GA19219@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120117092838.GB10397@elte.hu>
 <20120117102231.GB15447@linux.vnet.ibm.com>
 <20120117112239.GA23859@elte.hu>
 <20120117115705.GD15447@linux.vnet.ibm.com>
 <20120117122350.GD4959@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120117122350.GD4959@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


a couple of other 'perf probe' suggestions:

i think the 'perf probe' UI should be streamlined.

Right now we have kprobes assumptions like this syntax:

  perf probe <kernel_symbol>

will add a probe.

That is nonsensical once we merge uprobes, as i'd expect much 
more developers to be interested in user-space symbols than 
kernel-space symbols.

So we could change this syntax and add the more intuitive:

  perf probe add ...
  perf probe del ...
  perf probe list

Variants. Also, the -x syntax isnt particularly intuitive either 
- it should be a 'perf probe add ...' variant.

If someone uses the old syntax it will produce a meaningful 
error message.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
