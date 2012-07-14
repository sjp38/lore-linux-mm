Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A368B6B005A
	for <linux-mm@kvack.org>; Sat, 14 Jul 2012 12:21:46 -0400 (EDT)
Message-ID: <50019C5E.8020508@redhat.com>
Date: Sat, 14 Jul 2012 12:20:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
References: <20120316144028.036474157@chello.nl> <20120316144241.012558280@chello.nl> <4FFF4987.4050205@redhat.com> <5000347E.1050301@hp.com>
In-Reply-To: <5000347E.1050301@hp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/13/2012 10:45 AM, Don Morris wrote:

>> IIRC the test consisted of a 16GB NUMA system with two 8GB nodes.
>> It was running 3 KVM guests, two guests of 3GB memory each, and
>> one guest of 6GB each.
>
> How many cpus per guest (host threads) and how many physical/logical
> cpus per node on the host? Any comparisons with a situation where
> the memory would fit within nodes but the scheduling load would
> be too high?

IIRC this particular test was constructed to have guests
A and B fit in one NUMA node, with guest C in the other
NUMA node.

With schednuma, guest A ended up on one NUMA node, guest
B on the other, and guest C was spread between both nodes.

Only migrating when there is plenty of free space available
means you can end up not doing the right thing when running
a few large workloads on the system.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
