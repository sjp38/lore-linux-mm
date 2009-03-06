Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E30126B0083
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 16:16:22 -0500 (EST)
Date: Fri, 6 Mar 2009 13:16:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Patch] mm tracepoints
Message-Id: <20090306131603.8cf0ab22.akpm@linux-foundation.org>
In-Reply-To: <1236291400.1476.50.camel@dhcp-100-19-198.bos.redhat.com>
References: <497DD8E5.1040305@nortel.com>
	<20090126075957.69b64a2e@infradead.org>
	<497F5289.404@nortel.com>
	<m1vds0bj2j.fsf@fess.ebiederm.org>
	<20090128193813.GD1222@ucw.cz>
	<1233306324.11332.11.camel@nigel-laptop>
	<1236291400.1476.50.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, rostedt@goodmis.org, peterz@infradead.org, fweisbec@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 05 Mar 2009 17:16:40 -0500
Larry Woodman <lwoodman@redhat.com> wrote:

> I've implemented several mm tracepoints to track page allocation and
> freeing, various types of pagefaults and unmaps, and critical page
> reclamation routines.  This is useful for debugging memory allocation
> issues and system performance problems under heavy memory loads:
> 
> # tracer: mm
> #
> #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
> #              | |       |          |         |
>          pdflush-624   [004]   184.293169: wb_kupdate:
> (mm_pdflush_kupdate) count=3e48
>          pdflush-624   [004]   184.293439: get_page_from_freelist:
> (mm_page_allocation) pfn=447c27 zone_free=1940910
>         events/6-33    [006]   184.962879: free_hot_cold_page:
> (mm_page_free) pfn=44bba9
>       irqbalance-8313  [001]   188.042951: unmap_vmas:
> (mm_anon_userfree) mm=ffff88044a7300c0 address=7f9a2eb70000 pfn=24c29a
>              cat-9122  [005]   191.141173: filemap_fault:
> (mm_filemap_fault) primary fault: mm=ffff88024c9d8f40 address=3cea2dd000
> pfn=44d68e
>              cat-9122  [001]   191.143036: handle_mm_fault:
> (mm_anon_fault) mm=ffff88024c8beb40 address=7fffbde99f94 pfn=24ce22
> ...

I'm struggling to think of any memory management problems which this
facility would have helped us solve.  Single-page tracing like this
isn't very interesting or useful.

What we generally are looking for when resolving MM
performance/correctness problems is a representation/visualisation of
aggregated results over a period of time.  That means synchronous or
downstream processing of large amounts of bulk data.

Now, possibly the above information could be used to generate the
needed information.  But the above rather random-looking and chaotic
data output would make it very hard to develop the needed
aggregation/representation tools.

And unless someone actually develops those tools (which is a lot of
work), there isn't much point in adding the kernel infrastructure to
generate the data for the non-existing tool.

I haven't looked at LTT in a while.  What sort of information does it
extract from the MM system?  Is it useful to MM developers?  If so, can
this newly-proposed facility do the same thing?


How about a test case - how could this patch help us (and our testers)
make some progress with the infamous
http://bugzilla.kernel.org/show_bug.cgi?id=12309 ?


Then again, maybe I'm wrong!  Maybe MM developers _do_ believe that
this tool would assist them in their work.  Given that MM develoeprs
are the target market for this feature, it would be sensible to cc the
linux-mm list, methinks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
