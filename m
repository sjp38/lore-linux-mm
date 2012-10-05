Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 2F2A16B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 19:09:37 -0400 (EDT)
Message-ID: <506F687E.3030002@redhat.com>
Date: Fri, 05 Oct 2012 19:08:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/33] AutoNUMA27
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <20121004113943.be7f92a0.akpm@linux-foundation.org>
In-Reply-To: <20121004113943.be7f92a0.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 10/04/2012 02:39 PM, Andrew Morton wrote:
> On Thu,  4 Oct 2012 01:50:42 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
>
>> This is a new AutoNUMA27 release for Linux v3.6.
>
> Peter's numa/sched patches have been in -next for a week.

It may be worth pointing out that several of those patches have
quietly slipped into -next without any prior review on lkml.

That is not the way things should go, IMHO.

> Guys, what's the plan here?

My previous email outlined some of the situation and what I
have been doing, but does not actually have a plan.

Me helping improve both code bases does not seem to have
gotten either of the two closer to merging...

I guess "prod Andrew, Hugh, Mel, and others to test and review
both NUMA code bases" might be a plan?

Does anybody have any ideas?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
