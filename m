Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76EB36B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 13:20:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so3914632pfd.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:20:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id m6si7333138pfj.88.2016.07.27.10.20.49
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 10:20:49 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
 <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
 <20160727112303.11409a4e@gandalf.local.home>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5798ED5C.1020300@intel.com>
Date: Wed, 27 Jul 2016 10:20:28 -0700
MIME-Version: 1.0
In-Reply-To: <20160727112303.11409a4e@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On 07/27/2016 08:23 AM, Steven Rostedt wrote:
>> > +
>> > +	trace_mm_slowpath_end(page);
>> > +
> I'm thinking you only need one tracepoint, and use function_graph
> tracer for the length of the function call.
> 
>  # cd /sys/kernel/debug/tracing
>  # echo __alloc_pages_nodemask > set_ftrace_filter
>  # echo function_graph > current_tracer
>  # echo 1 > events/kmem/trace_mm_slowpath/enable

I hesitate to endorse using the function_graph tracer for this kind of
stuff.  Tracepoints offer some level of stability in naming, and the
compiler won't ever make them go away.   While __alloc_pages_nodemask is
probably more stable than most things, there's no guarantee that it will
be there.

BTW, what's the overhead of the function graph tracer if the filter is
set up to be really restrictive like above?  Is the overhead really just
limited to that one function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
