Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 149D96B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 07:12:13 -0400 (EDT)
Received: by wibhn6 with SMTP id hn6so3270382wib.8
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 04:12:11 -0700 (PDT)
Date: Sat, 14 Apr 2012 13:12:06 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface for
 uprobes
Message-ID: <20120414111206.GA24688@gmail.com>
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
 <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com>
 <20120411103043.GB29437@linux.vnet.ibm.com>
 <1334236456.23924.333.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334236456.23924.333.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>


* Steven Rostedt <rostedt@goodmis.org> wrote:

> I'm fine with what I see here (still need to fix what Masami 
> suggested).
> 
> Acked-by: Steven Rostedt <rostedt@goodmis.org>

Ok - Srikar, mind sending the latest (3-patch?) series again, 
with all suggestions and acks incorporated?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
