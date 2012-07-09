Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 7F5706B006E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:55:28 -0400 (EDT)
Message-ID: <4FFAF0A9.7060509@redhat.com>
Date: Mon, 09 Jul 2012 10:54:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
References: <20120316144028.036474157@chello.nl>  <20120316144241.012558280@chello.nl> <4FF9D2EF.7010901@redhat.com> <1341836705.3462.62.camel@twins>
In-Reply-To: <1341836705.3462.62.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/09/2012 08:25 AM, Peter Zijlstra wrote:
> On Sun, 2012-07-08 at 14:35 -0400, Rik van Riel wrote:
>>
>> This looks like something that should be fixed before the
>> code is submitted for merging upstream.
>
> static bool __task_can_migrate(struct task_struct *t, u64 *runtime, int node)
> {
...
> is what it looks like..

Looks good to me.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
