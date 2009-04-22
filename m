Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D69C86B00B2
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 08:11:03 -0400 (EDT)
Subject: Re: [Patch] mm tracepoints update
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20090422095727.GG18226@elte.hu>
References: <1240353915.11613.39.camel@dhcp-100-19-198.bos.redhat.com>
	 <20090422095916.627A.A69D9226@jp.fujitsu.com>
	 <20090422095727.GG18226@elte.hu>
Content-Type: text/plain
Date: Wed, 22 Apr 2009 08:07:17 -0400
Message-Id: <1240402037.4682.3.camel@dhcp47-138.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-22 at 11:57 +0200, Ingo Molnar wrote:
> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > I've cleaned up the mm tracepoints to track page allocation and 
> > > freeing, various types of pagefaults and unmaps, and critical 
> > > page reclamation routines.  This is useful for debugging memory 
> > > allocation issues and system performance problems under heavy 
> > > memory loads.
> > 
> > In past thread, Andrew pointed out bare page tracer isn't useful. 
> 
> (do you have a link to that mail?)
> 
> > Can you make good consumer?

I will work up some good examples of what these are useful for.  I use
the mm tracepoint data in the debugfs trace buffer to locate customer
performance problems associated with memory allocation, deallocation,
paging and swapping frequently, especially on large systems.

Larry

> 
> These MM tracepoints would be automatically seen by the 
> ftrace-analyzer GUI tool for example:
> 
>   git://git.kernel.org/pub/scm/utils/kernel/ftrace/ftrace.git
> 
> And could also be seen by other tools such as kmemtrace. Beyond, of 
> course, embedding in function tracer output.
> 
> Here's the list of advantages of the types of tracepoints Larry is 
> proposing:
> 
>   - zero-copy and per-cpu splice() based tracing
>   - binary tracing without printf overhead
>   - structured logging records exposed under /debug/tracing/events
>   - trace events embedded in function tracer output and other plugins
>   - user-defined, per tracepoint filter expressions
> 
> I think the main review question is: are they properly structured 
> and do they expose essential information to analyze behavioral 
> details of the kernel in this area?
> 
> 	Ingo
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
