Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id DC9A96B009D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 06:12:46 -0500 (EST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 17 Jan 2012 04:12:45 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DC22319D8049
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:12:38 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0HBCeQv131702
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:12:40 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0HBCZNu032598
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:12:39 -0700
Date: Tue, 17 Jan 2012 16:33:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 7/9] tracing: uprobes trace_event interface
Message-ID: <20120117110345.GC15447@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <20120110114943.17610.28293.sendpatchset@srdronam.in.ibm.com>
 <20120116131137.GB5265@m.brq.redhat.com>
 <20120117092838.GB10397@elte.hu>
 <20120117102231.GB15447@linux.vnet.ibm.com>
 <20120117105916.GA3664@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120117105916.GA3664@elte.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jiri Olsa <jolsa@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

* Ingo Molnar <mingo@elte.hu> [2012-01-17 11:59:16]:

> 
> btw., i'd write the CONFIG_UPROBE_EVENT .config help text:
> 
>  This allows the user to add tracing events on top of userspace
>  dynamic events (similar to tracepoints) on the fly via the
>  traceevents interface. Those events can be inserted wherever 
>  uprobes can probe, and record various registers.
> 
>  This option is required if you plan to use perf-probe 
>  subcommand of perf tools on user space applications.
> 
> In a clearer form:
> 
>  This allows the user to add user-space dynamic events on the 
>  fly, similar to tracepoints. These events can be inserted
>  into just about any user-space code transparently, and can 
>  record register state there on the fly, which is then used by
>  instrumentation tools.
> 
>  This option is required if you plan to use the "perf probe"
>  subcommand of the perf tool on user space applications.
> 

Okay, Will change as suggested.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
