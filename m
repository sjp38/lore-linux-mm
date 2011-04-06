Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9E518D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 18:42:03 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p36MGrGH013817
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 18:16:53 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id EB96B38C8038
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 18:41:44 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p36MfrWF2678984
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 18:41:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p36MfpdO024213
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 18:41:52 -0400
Date: Thu, 7 Apr 2011 04:11:48 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2.6.39-rc1-tip 26/26] 26: uprobes: filter chain
Message-ID: <20110406224148.GA5806@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
 <20110401143737.15455.30181.sendpatchset@localhost6.localdomain6>
 <4D9A6FE8.2010301@hitachi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4D9A6FE8.2010301@hitachi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>

> > +static bool filter_chain(struct uprobe *uprobe, struct task_struct *t)
> > +{
> > +	struct uprobe_consumer *consumer;
> > +	bool ret = false;
> > +
> > +	down_read(&uprobe->consumer_rwsem);
> > +	for (consumer = uprobe->consumers; consumer;
> > +					consumer = consumer->next) {
> > +		if (!consumer->filter || consumer->filter(consumer, t)) {
> > +			ret = true;
> > +			break;
> > +		}
> > +	}
> > +	up_read(&uprobe->consumer_rwsem);
> > +	return ret;
> > +}
> > +
> 
> Where this function is called from ? This patch seems the last one of this series...
> 

Sorry for the delayed reply, I was travelling to LFCS.
Still I have to connect the filter from trace/perf probe. 
Thats listed as todo and thats the next thing I am planning to work on.
Once we have the connect, this filter_chain and filters that we defined
will be used. Till then these two patches, One that defines filter_chain
and one that defines filters are useless.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
