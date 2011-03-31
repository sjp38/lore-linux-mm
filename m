Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9B5A88D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:59:35 -0400 (EDT)
Date: Thu, 31 Mar 2011 17:59:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
Message-ID: <20110331155931.GG12265@random.random>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org

Hi KAMEZAWA,

On Thu, Mar 31, 2011 at 11:01:13AM +0900, KAMEZAWA Hiroyuki wrote:
> 1. Memory cgroup : Where next ? 1hour (Balbir Singh/Kamezawa) 

Originally it was 30min and then there was a topic "Working set
estimation" for another 30 min. That has been converted to "what's
next continued", so I assume that you can add the Working set
estimation as a subtopic.

> 2. Memcg Dirty Limit and writeback 30min(Greg Thelen)
> 3. Memcg LRU management 30min (Ying Han, Michal Hocko)
> 4. Page cgroup on a diet (Johannes Weiner)
> 2.5 hours. This seems long...or short ? ;)

Overall we've been seeing plenty of memcg emails, so I guess 2.5 hours
are ok. And I wouldn't say we're not in the short side.

I thought it was better to keep "what's next as last memcg topic" but
Hugh suggested it as first topic, no problem with the order on my
side. Now the first topic doubled in time ;).

> I'd like to sort out topics before going. Please fix if I don't catch enough.

I agree that's good practice, to prepare some material and have a
plan.

> Main topics on 1.Memory control groups: where next? is..
> 
> To be honest, I just do bug fixes in these days. And hot topics are on above..
> I don't have concrete topics. What I can think of from recent linux-mm emails are...
> 
>   a) Kernel memory accounting.
>   b) Need some work with Cleancache ?
>   c) Should we provide a auto memory cgroup for file caches ?
>      (Then we can implement a file-cache-limit.)
>   d) Do we have a problem with current OOM-disable+notifier design ?
>   e) ROOT cgroup should have a limit/softlimit, again ?
>   f) vm_overcommit_memory should be supproted with memcg ?
>      (I remember there was a trial. But I think it should be done in other cgroup
>       as vmemory cgroup.)
> ...
> 
> I think
>   a) discussing about this is too early. There is no patch.
>      I think we'll just waste time.

Hugh was thinking about this as a subtopic, I'm not intrigued by it
personally so I don't mind to skip it. I can imagine some people
liking it though. Maybe you can mention it and see if somebody has
contact with customers who needs this and if it's worth the pain for
them.

>   b) enable/disable cleancache per memcg or some share/limit ??
>      But we can discuss this kind of things after cleancache is in production use...

Kind of agreed we can skip this on my side, but I may be biased
because cleancache is not really useful to anything like KVM at least
(we already have writeback default and wirththrough by just using
O_SYNC without requiring a flood of hypercalls and vmexits even with
light I/O activity). We'll hear about the new novirt users of
transcendent memory, in Dan's talk before memcg starts.

>   c) AFAIK, some other OSs have this kind of feature, a box for file-cache.
>      Because file-cache is a shared object between all cgroups, it's difficult
>      to handle. It may be better to have a auto cgroup for file caches and add knobs
>      for memcg.
> 
>   d) I think it works well. 
> 
>   e) It seems Michal wants this for lazy users. Hmm, should we have a knob ?
>      It's helpful that some guy have a performance number on the latest kernel
>      with and without memcg (in limitless case).
>      IIUC, with THP enabled as 'always', the number of page fault dramatically reduced and
>      memcg's accounting cost gets down...
> 
>   f) I think someone mention about this...
> 
> Maybe c) and d) _can_ be a topic but seems not very important.
>
> So, for this slot, I'd like to discuss
> 
>   I) Softlimit/Isolation (was 3-A) for 1hour
>      If we have extra time, kernel memory accounting or file-cache handling
>      will be good.

Sounds good but for the what's next 1 hour slot I would keep more
subtopics like some of the ones you mentioned (if nothing else for the
second half hour) and then we see how things evolve. Maybe Michel
L. still want to talk about Working set estimation too in the second
half hour.

>   II) Dirty page handling. (for 30min)
>      Maybe we'll discuss about per-memcg inode queueing issue.
> 
>   III) Discussing the current and future design of LRU.(for 30+min)
> 
>   IV) Diet of page_cgroup (for 30-min)
>       Maybe this can be combined with III.

Looks a good plan to me, but others are more directly involved in
memcg than me so feel free to decide! About the diet topic it was
suggested by Johannes so I'll let him comment on it if he wants.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
