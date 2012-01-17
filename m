Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 65DEF6B0075
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 06:22:57 -0500 (EST)
Date: Tue, 17 Jan 2012 12:22:39 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120117112239.GA23859@elte.hu>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120117092838.GB10397@elte.hu>
 <20120117102231.GB15447@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120117102231.GB15447@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>


Srikar, rebased commits like this one:

  c5af743: rcu: Introduce raw SRCU read-side primitives

are absolutely inacceptable:

 commit c5af7439f322db86e347991e184b95dd80676967
 Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
 Date:   Sun Oct 9 15:13:11 2011 -0700

    rcu: Introduce raw SRCU read-side primitives

    ...

    Requested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Tested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

If you pull a commit from Paul into your tree then you must 
never rebase it. If you applied Paul's commit out of email then 
you should add a Signed-off-by, not a Tested-by tag at the end.

Also, please test whether it works when merged to latest -tip, 
there's been various RCU changes in this area. AFAICS these 
read-side primitives are already upstream via:

  0c53dd8b3140: rcu: Introduce raw SRCU read-side primitives

so pulling your tree would break the build.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
