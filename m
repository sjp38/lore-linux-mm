Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D9C476B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 05:58:36 -0400 (EDT)
Message-ID: <4F670325.7080700@redhat.com>
Date: Mon, 19 Mar 2012 11:57:57 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl>
In-Reply-To: <20120316144028.036474157@chello.nl>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/16/2012 04:40 PM, Peter Zijlstra wrote:
> The home-node migration handles both cpu and memory (anonymous only for now) in
> an integrated fashion. The memory migration uses migrate-on-fault to avoid
> doing a lot of work from the actual numa balancer kernl thread and only
> migrates the active memory.
>

IMO, this needs to be augmented with eager migration, for the following
reasons:

- lazy migration adds a bit of latency to page faults
- doesn't work well with large pages
- doesn't work with dma engines

So I think that in addition to migrate on fault we need a background
thread to do eager migration.  We might prioritize pages based on the
active bit in the PDE (cheaper to clear and scan than the PTE, but gives
less accurate information).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
