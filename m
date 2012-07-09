Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 703966B006E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:53:59 -0400 (EDT)
Message-ID: <4FFAF067.3050905@redhat.com>
Date: Mon, 09 Jul 2012 10:53:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 25/26] sched, numa: Only migrate long-running entities
References: <20120316144028.036474157@chello.nl>  <20120316144241.749359061@chello.nl> <4FF9D29D.8030903@redhat.com> <1341836787.3462.64.camel@twins>
In-Reply-To: <1341836787.3462.64.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/09/2012 08:26 AM, Peter Zijlstra wrote:
> On Sun, 2012-07-08 at 14:34 -0400, Rik van Riel wrote:

>> Do we really want to calculate the amount of CPU time used
>> by a process, and start migrating after just one second?
>>
>> Or would it be ok to start migrating once a process has
>> been scanned once or twice by the NUMA code?
>
> You mean, the 2-3rd time we try and migrate this task, not the memory
> scanning thing as per Andrea, right?

Indeed.  That way we can simply keep a flag somewhere,
instead of iterating over the threads in a process.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
