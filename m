Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 458A56B0083
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 08:27:44 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 19 Mar 2012 12:25:15 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2JCLf6V3518650
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 23:21:41 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2JCRXpj024062
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 23:27:34 +1100
Message-ID: <4F672629.60606@linux.vnet.ibm.com>
Date: Mon, 19 Mar 2012 17:57:22 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 15/26] sched, numa: Implement hotplug hooks
References: <20120316144028.036474157@chello.nl> <20120316144241.074193109@chello.nl> <4F672384.7030500@linux.vnet.ibm.com> <1332159598.18960.320.camel@twins>
In-Reply-To: <1332159598.18960.320.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/19/2012 05:49 PM, Peter Zijlstra wrote:

> On Mon, 2012-03-19 at 17:46 +0530, Srivatsa S. Bhat wrote:
>>> +     get_online_cpus();
>>> +     cpu_notifier(numa_hotplug, 0);
>>
>>
>> ABBA deadlock!
>>
> Yeah, I know.. luckily it can't actually happen since early_initcalls
> are pre-smp. I could just leave out the get_online_cpus() thing.
> 


Oh numa_init() is an early_initcall? Ok, I didn't observe.
In that case, its fine either way, with or without get_online_cpus()
stuff.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
