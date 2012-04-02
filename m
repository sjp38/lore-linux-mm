Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 588B76B007E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 12:45:55 -0400 (EDT)
Message-ID: <4F79D9F1.7030504@redhat.com>
Date: Mon, 02 Apr 2012 12:55:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl> <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins> <20120319130401.GI24602@redhat.com> <1332163591.18960.334.camel@twins> <20120319135745.GL24602@redhat.com> <4F673D73.90106@redhat.com> <20120319143002.GQ24602@redhat.com> <1332182523.18960.372.camel@twins> <4F69022D.3080300@redhat.com> <CAOJsxLHPc7QxdsUADikgeqQo7WVCzUD1KoHRT7Ngr7xXM_F7ig@mail.gmail.com>
In-Reply-To: <CAOJsxLHPc7QxdsUADikgeqQo7WVCzUD1KoHRT7Ngr7xXM_F7ig@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/02/2012 12:34 PM, Pekka Enberg wrote:
> On Wed, Mar 21, 2012 at 12:18 AM, Rik van Riel<riel@redhat.com>  wrote:
>> I suspect Java and other runtimes may have issues where
>> they simply do not know which thread will end up using
>> which objects from the heap heavily.
>
> What kind of JVM workloads are you thinking of? Modern GCs use
> thread-local allocation for performance reasons so I'd assume that
> most of accesses are on local node.

Yes, the use thread-local allocation.

However, I suspect that after the memory has been allocated
locally, it may quite often end up with another thread for
further processing...

The JVM doing the right thing only helps so much, when the
Java program has no way to know about underlying things,
or influence how the threads get scheduled on the JVM.

Allowing us to discover which threads are accessing the
same data, and figuring out what data each thread uses,
could be useful for NUMA placement...

I have some ideas on how to gather the information that
Andrea is gathering, with less space overhead. I will
try to present that idea today...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
