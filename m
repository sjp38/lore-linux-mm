Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C1A276B00A9
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 05:56:54 -0400 (EDT)
Date: Wed, 22 Apr 2009 11:57:27 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Patch] mm tracepoints update
Message-ID: <20090422095727.GG18226@elte.hu>
References: <1240353915.11613.39.camel@dhcp-100-19-198.bos.redhat.com> <20090422095916.627A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090422095916.627A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro
Cc: Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > I've cleaned up the mm tracepoints to track page allocation and 
> > freeing, various types of pagefaults and unmaps, and critical 
> > page reclamation routines.  This is useful for debugging memory 
> > allocation issues and system performance problems under heavy 
> > memory loads.
> 
> In past thread, Andrew pointed out bare page tracer isn't useful. 

(do you have a link to that mail?)

> Can you make good consumer?

These MM tracepoints would be automatically seen by the 
ftrace-analyzer GUI tool for example:

  git://git.kernel.org/pub/scm/utils/kernel/ftrace/ftrace.git

And could also be seen by other tools such as kmemtrace. Beyond, of 
course, embedding in function tracer output.

Here's the list of advantages of the types of tracepoints Larry is 
proposing:

  - zero-copy and per-cpu splice() based tracing
  - binary tracing without printf overhead
  - structured logging records exposed under /debug/tracing/events
  - trace events embedded in function tracer output and other plugins
  - user-defined, per tracepoint filter expressions

I think the main review question is: are they properly structured 
and do they expose essential information to analyze behavioral 
details of the kernel in this area?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
