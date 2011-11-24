Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C046D6B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 08:43:43 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 24 Nov 2011 06:43:42 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAODchrd066850
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 06:39:23 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAODcfC3006182
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 06:38:42 -0700
Date: Thu, 24 Nov 2011 19:07:35 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 3.2-rc2 4/30] uprobes: Define hooks for mmap/munmap.
Message-ID: <20111124133735.GG28065@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
 <20111118110723.10512.66282.sendpatchset@srdronam.in.ibm.com>
 <1322072149.14799.89.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1322072149.14799.89.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, tulasidhard@gmail.com

* Peter Zijlstra <peterz@infradead.org> [2011-11-23 19:15:49]:

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

I use stgit 
You had suggested this to me earlier, and I have it my ~/.gitconfig


[diff "default"]
        xfuncname = "^[[:alpha:]$_].*[^:]$"


 stg version 
 Stacked GIT 0.15
 git version 1.7.1
 Python version 2.6.6 (r266:84292, Apr 11 2011, 15:50:32) 
 [GCC 4.4.4 20100726 (Red Hat 4.4.4-13)]

One thing that I might be doing differently is 

I do a "stg export" before using sendpatchset to mail the patches.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
