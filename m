Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 349166B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:19:02 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 12 Apr 2012 11:19:00 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6E85C6E80B3
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:18:38 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3CFIbL1067066
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:18:37 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3CFICbq031372
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:18:14 -0600
Date: Thu, 12 Apr 2012 20:40:37 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: Re: [PATCH] perf/probe: Provide perf interface for uprobes
Message-ID: <20120412151037.GC21587@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120411135742.29198.45061.sendpatchset@srdronam.in.ibm.com>
 <20120411144918.GD16257@infradead.org>
 <20120411170343.GB29831@linux.vnet.ibm.com>
 <20120411181727.GK16257@infradead.org>
 <4F864BB3.3090405@hitachi.com>
 <20120412140751.GM16257@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120412140751.GM16257@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

>  $ perf probe libc malloc
> 
> 	Makes it even easier to use.
> 
> 	Its just when one asks for something that has ambiguities that
> the tool should ask the user to be a bit more precise to remove such
> ambiguity.
> 
> 	After all...
> 

Another case 
perf probe do_fork clone_flags now looks for variable clone_flags in
kernel function do_fork.

But if we allow to trace perf probe zsh zfree; then 
'perf probe do_fork clone_flags' should it check for do_fork executable
or not? If it does check and finds one, and searches for clone_flags
function and doesnt find, then should it continue with searching the
kernel?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
