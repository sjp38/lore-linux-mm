Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 17C286B004D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 19:42:30 -0400 (EDT)
Date: Thu, 22 Mar 2012 00:41:56 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120321234156.GP24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <20120316182511.GJ24602@redhat.com>
 <87k42edenh.fsf@danplanet.com>
 <20120321021239.GQ24602@redhat.com>
 <87fwd2d2kp.fsf@danplanet.com>
 <20120321124937.GX24602@redhat.com>
 <87limtboet.fsf@danplanet.com>
 <20120321225242.GL24602@redhat.com>
 <87aa39bl92.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87aa39bl92.fsf@danplanet.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Dan,

On Wed, Mar 21, 2012 at 04:13:45PM -0700, Dan Smith wrote:
> AA> available: 2 nodes (0-1)
> AA> node 0 cpus: 0 1 2 3 4 5 12 13 14 15 16 17
> AA> node 1 cpus: 6 7 8 9 10 11 18 19 20 21 22 23
> 
> available: 2 nodes (0-1)
> node 0 cpus: 0 1 2 3 4 5 12 13 14 15 16 17
> node 0 size: 12276 MB
> node 0 free: 11769 MB
> node 1 cpus: 6 7 8 9 10 11 18 19 20 21 22 23
> node 1 size: 12288 MB
> node 1 free: 11727 MB
> node distances:
> node   0   1 
>   0:  10  21 
>   1:  21  10 
> 
> Same enough?

Yes. Just more RAM than me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
