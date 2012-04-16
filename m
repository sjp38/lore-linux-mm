Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 99E716B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 05:30:36 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 03:30:35 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3519119D804E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 03:30:24 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3G9USe6190976
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 03:30:30 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3G9UQsZ001868
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 03:30:27 -0600
Date: Mon, 16 Apr 2012 14:52:27 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface
 for uprobes
Message-ID: <20120416092227.GD13363@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
 <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com>
 <20120411103043.GB29437@linux.vnet.ibm.com>
 <1334236456.23924.333.camel@gandalf.stny.rr.com>
 <20120414111206.GA24688@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120414111206.GA24688@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

* Ingo Molnar <mingo@kernel.org> [2012-04-14 13:12:06]:

> 
> * Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> > I'm fine with what I see here (still need to fix what Masami 
> > suggested).
> > 
> > Acked-by: Steven Rostedt <rostedt@goodmis.org>
> 
> Ok - Srikar, mind sending the latest (3-patch?) series again, 
> with all suggestions and acks incorporated?
> 

Just sent out the 3 patches incorporation all suggestions including the
last one from Stephen Boyd.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
