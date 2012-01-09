Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 459FE6B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 06:32:56 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 9 Jan 2012 04:32:54 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q09BWBpH149442
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 04:32:11 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q09BW8uR004109
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 04:32:10 -0700
Date: Mon, 9 Jan 2012 16:54:27 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v8 3.2.0-rc5 9/9] perf: perf interface for uprobes
Message-ID: <20120109112427.GB10189@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111216122756.2085.95791.sendpatchset@srdronam.in.ibm.com>
 <20111216122951.2085.95511.sendpatchset@srdronam.in.ibm.com>
 <4F06D22D.9060906@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4F06D22D.9060906@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, yrl.pp-manager.tt@hitachi.com

> 
> > +
> > +static int convert_to_perf_probe_point(struct probe_trace_point *tp,
> > +					struct perf_probe_point *pp)
> > +{
> > +	pp->function = strdup(tp->symbol);
> > +	if (pp->function == NULL)
> > +		return -ENOMEM;
> > +	pp->offset = tp->offset;
> > +	pp->retprobe = tp->retprobe;
> > +
> > +	return 0;
> > +}
> 
> This function could be used in kprobe_convert_to_perf_probe() too.
> In that case, it will be separated as a cleanup from this.

Do you really want this in a separate patch, since it doesnt make too
much sense without the uprobes code.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
