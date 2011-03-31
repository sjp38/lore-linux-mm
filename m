Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3694B8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:20:55 -0400 (EDT)
Date: Thu, 31 Mar 2011 18:20:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
Message-ID: <20110331162050.GI12265@random.random>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <4D944801.3020404@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D944801.3020404@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: lsf@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>

On Thu, Mar 31, 2011 at 01:23:13PM +0400, Pavel Emelyanov wrote:
> >  b) single LRU and per memcg zone->lru_lock.
> >     I hear zone->lru_lock contention caused by memcg is a problem on Google servers.
> >     Okay, please show data. (I've never seen it.)
> >     Then, we need to discuss Pros. and Cons. of current design and need to consinder
> >     how to improve it. I think Google and Michal have their own implementation.
> > 
> >     Current design of double-LRU is from the 1st inclusion of memcg to the kernel.
> >     But I don't know that discussion was there. Balbir, could you explain the reason
> >     of this design ? Then, we can go ahead, somewhere.
> 
> I would like to take part in that and describe what we've done with LRU
> in OpenVZ in details.

Sounds good.

>
> >   a) Kernel memory accounting.
> 
> This one is very interesting to me.

I expected someone would have been interested into that...

> >   f) vm_overcommit_memory should be supproted with memcg ?
> >      (I remember there was a trial. But I think it should be done in other cgroup
> >       as vmemory cgroup.)
> 
> And this one too - I have an implementation of overcommit management
> in OpenVZ, I can describe one and discuss pros-n-cons.

Ok, so I've added you to the second half of "what's next".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
