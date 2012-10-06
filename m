Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 5D5506B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 20:11:35 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/33] AutoNUMA27
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
	<20121004113943.be7f92a0.akpm@linux-foundation.org>
	<m24nm8wly3.fsf@firstfloor.org>
	<1349481433.17632.62.camel@schen9-DESK>
Date: Fri, 05 Oct 2012 17:11:33 -0700
In-Reply-To: <1349481433.17632.62.camel@schen9-DESK> (Tim Chen's message of
	"Fri, 05 Oct 2012 16:57:13 -0700")
Message-ID: <m2zk40v4qy.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex@linux.intel.com, Sh@linux.intel.com

Tim Chen <tim.c.chen@linux.intel.com> writes:
>> 
>
> I remembered that 3 months ago when Alex tested the numa/sched patches
> there were 20% regression on SpecJbb2005 due to the numa balancer.

20% on anything sounds like a show stopper to me.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
