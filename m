Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3008D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 05:23:23 -0400 (EDT)
Message-ID: <4D944801.3020404@parallels.com>
Date: Thu, 31 Mar 2011 13:23:13 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf@lists.linux-foundation.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>

>  b) single LRU and per memcg zone->lru_lock.
>     I hear zone->lru_lock contention caused by memcg is a problem on Google servers.
>     Okay, please show data. (I've never seen it.)
>     Then, we need to discuss Pros. and Cons. of current design and need to consinder
>     how to improve it. I think Google and Michal have their own implementation.
> 
>     Current design of double-LRU is from the 1st inclusion of memcg to the kernel.
>     But I don't know that discussion was there. Balbir, could you explain the reason
>     of this design ? Then, we can go ahead, somewhere.

I would like to take part in that and describe what we've done with LRU
in OpenVZ in details.

>   a) Kernel memory accounting.

This one is very interesting to me.

>   f) vm_overcommit_memory should be supproted with memcg ?
>      (I remember there was a trial. But I think it should be done in other cgroup
>       as vmemory cgroup.)

And this one too - I have an implementation of overcommit management
in OpenVZ, I can describe one and discuss pros-n-cons.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
