Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id A7E256B00A0
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 07:07:01 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 17 Jan 2012 05:06:59 -0700
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C78E31FF00A3
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:06:16 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0HC6HI0276352
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 07:06:17 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0HC669J029603
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:06:07 -0700
Date: Tue, 17 Jan 2012 17:27:05 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120117115705.GD15447@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120117092838.GB10397@elte.hu>
 <20120117102231.GB15447@linux.vnet.ibm.com>
 <20120117112239.GA23859@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120117112239.GA23859@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

> Srikar, rebased commits like this one:
> 
>   c5af743: rcu: Introduce raw SRCU read-side primitives
> 
> are absolutely inacceptable:
> 

Okay, I wasnt sure whats the best way for me to expose a tree such that
people who just use my tree to try (without basing on any other trees
except Linus) can build and use uprobes but people who already have this
commit arent affected by me having this commit.

So couple of people did tell me that git was intelligent enuf that if
the commit was already in, it would create a empty commit. 

do you have suggestions on how to work around such situations in future?

>  commit c5af7439f322db86e347991e184b95dd80676967
>  Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>  Date:   Sun Oct 9 15:13:11 2011 -0700
> 
>     rcu: Introduce raw SRCU read-side primitives
> 
>     ...
> 
>     Requested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>     Tested-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> 
> If you pull a commit from Paul into your tree then you must 
> never rebase it. If you applied Paul's commit out of email then 
> you should add a Signed-off-by, not a Tested-by tag at the end.

I actually cherry-picked commit from your tree i.e -tip. 
The Tested-by tag was added by Paul after I confirmed to him that it
works.  Even the commit 0c53dd8b3140: that you refer has the same tags.

> 
> Also, please test whether it works when merged to latest -tip, 
> there's been various RCU changes in this area. AFAICS these 
> read-side primitives are already upstream via:
> 
>   0c53dd8b3140: rcu: Introduce raw SRCU read-side primitives
> 
> so pulling your tree would break the build.

I had used v3.2 as a base for my tree and 0c53dd8b3140: was not part of
that tag. Now that its gone into mainline, I will drop the commit.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
