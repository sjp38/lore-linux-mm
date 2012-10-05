Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 28B2E6B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 19:57:10 -0400 (EDT)
Subject: Re: [PATCH 00/33] AutoNUMA27
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <m24nm8wly3.fsf@firstfloor.org>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
	 <20121004113943.be7f92a0.akpm@linux-foundation.org>
	 <m24nm8wly3.fsf@firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 05 Oct 2012 16:57:13 -0700
Message-ID: <1349481433.17632.62.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad@linux.intel.com

On Fri, 2012-10-05 at 16:14 -0700, Andi Kleen wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Thu,  4 Oct 2012 01:50:42 +0200
> > Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> >> This is a new AutoNUMA27 release for Linux v3.6.
> >
> > Peter's numa/sched patches have been in -next for a week. 
> 
> Did they pass review? I have some doubts.
> 
> The last time I looked it also broke numactl.
> 
> > Guys, what's the plan here?
> 
> Since they are both performance features their ultimate benefit
> is how much faster they make things (and how seldom they make things
> slower)
> 
> IMHO needs a performance shot-out. Run both on the same 10 workloads
> and see who wins. Just a lot of of work. Any volunteers?
> 
> For a change like this I think less regression is actually more
> important than the highest peak numbers.
> 
> -Andi
> 

I remembered that 3 months ago when Alex tested the numa/sched patches
there were 20% regression on SpecJbb2005 due to the numa balancer.
Those issues may have been fixed but we probably need to run this
benchmark against the latest.  For most of the other kernel performance
workloads we ran we didn't see much changes.

Maurico has a different config for this benchmark and it will be nice
if he can also check to see if there are any performance changes on his
side.

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
