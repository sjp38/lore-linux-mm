Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id BFC796B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 15:29:12 -0400 (EDT)
Message-ID: <4F70C365.8020009@redhat.com>
Date: Mon, 26 Mar 2012 15:28:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>  <1332783986-24195-12-git-send-email-aarcange@redhat.com> <1332786353.16159.173.camel@twins>
In-Reply-To: <1332786353.16159.173.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>

On 03/26/2012 02:25 PM, Peter Zijlstra wrote:
> On Mon, 2012-03-26 at 19:45 +0200, Andrea Arcangeli wrote:
>> @@ -3220,6 +3214,8 @@ need_resched:
>>
>>          post_schedule(rq);
>>
>> +       sched_autonuma_balance();
>> +
>>          sched_preempt_enable_no_resched();
>>          if (need_resched())
>>                  goto need_resched;
>
> I already told you, this isn't ever going to happen. You do _NOT_ put a
> for_each_online_cpu() loop in the middle of schedule().

Agreed, it looks O(N), but because every CPU will be calling
it its behaviour will be O(N^2) and has the potential to
completely break systems with a large number of CPUs.

Finding a lower overhead way of doing the balancing does not
seem like an unsurmountable problem.

> You also do not call stop_one_cpu(migration_cpu_stop) in schedule to
> force migrate the task you just scheduled to away from this cpu. That's
> retarded.
>
> Nacked-by: Peter Zijlstra<a.p.zijlstra@chello.nl>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
