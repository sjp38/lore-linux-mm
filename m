Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 37AA36B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:15:55 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <habanero@linux.vnet.ibm.com>;
	Fri, 23 Mar 2012 08:15:54 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id E131D3E40050
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 08:15:50 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2NEFhGc253766
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 08:15:47 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2NEFZRV010599
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 08:15:40 -0600
Message-ID: <4F6C857A.3070307@linux.vnet.ibm.com>
Date: Fri, 23 Mar 2012 09:15:22 -0500
From: Andrew Theurer <habanero@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] AutoNUMA alpha6
References: <20120316182511.GJ24602@redhat.com> <87k42edenh.fsf@danplanet.com> <20120321021239.GQ24602@redhat.com> <87fwd2d2kp.fsf@danplanet.com> <20120321124937.GX24602@redhat.com> <87limtboet.fsf@danplanet.com> <20120321225242.GL24602@redhat.com>	<20120322001722.GQ24602@redhat.com> <873990buuy.fsf@danplanet.com>	<20120322142735.GE24602@redhat.com> <20120322184925.GT24602@redhat.com> <87limsa2hm.fsf@danplanet.com>
In-Reply-To: <87limsa2hm.fsf@danplanet.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/22/2012 01:56 PM, Dan Smith wrote:
> AA>  but now it's time to go back coding and add THP native
> AA>  migration. That will benefit everyone, from cpuset in userland to
> AA>  numa/sched.
>
> I dunno about everyone else, but I think the thing I'd like to see most
> (other than more interesting benchmarks)

We are working on the "more interesting benchmarks", starting with KVM 
workloads.  However, I must warn you all, more interesting = a lot more 
time to run.  These are a lot more complex in that they have real I/O, 
and they can be a lot more challenging because there are response time 
requirements (so fairness is an absolute requirement).  We are getting a 
baseline right now and re-running with our user-space VM-to-numa-node 
placement program, which in the past achieved manual binding performance 
or just slightly lower.  We can then compare to these two solutions.  If 
there's something specific to collect (perhaps you have a lot of stats 
or data in debugfs, etc) please let me know.

-Andrew Theurer
>   is a broken out and documented
> set of patches instead of the monolithic commit you have now. I know you
> weren't probably planning to do that until numasched came along, but it
> sure would help me digest the differences in the two approaches.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
