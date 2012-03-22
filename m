Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 821256B00E8
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 15:11:50 -0400 (EDT)
Date: Thu, 22 Mar 2012 20:11:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120322191121.GA6661@redhat.com>
References: <20120321021239.GQ24602@redhat.com>
 <87fwd2d2kp.fsf@danplanet.com>
 <20120321124937.GX24602@redhat.com>
 <87limtboet.fsf@danplanet.com>
 <20120321225242.GL24602@redhat.com>
 <20120322001722.GQ24602@redhat.com>
 <873990buuy.fsf@danplanet.com>
 <20120322142735.GE24602@redhat.com>
 <20120322184925.GT24602@redhat.com>
 <87limsa2hm.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87limsa2hm.fsf@danplanet.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 22, 2012 at 11:56:37AM -0700, Dan Smith wrote:
> AA> but now it's time to go back coding and add THP native
> AA> migration. That will benefit everyone, from cpuset in userland to
> AA> numa/sched.
> 
> I dunno about everyone else, but I think the thing I'd like to see most
> (other than more interesting benchmarks) is a broken out and documented
> set of patches instead of the monolithic commit you have now. I know you
> weren't probably planning to do that until numasched came along, but it
> sure would help me digest the differences in the two approaches.

I uploaded AutoNUMA public to my git tree autonuma branch, the day
before numa/sched was posted to allow people to start testing it. I
didn't announce it yet because I wasn't sure if it was worth posting
it until I had the time to split the patches. Then I changed my mind
and posted it as the monolith that it was.

I think I'll try to attack the THP native migration, if it looks like
it takes more than one or two days to do it, I'll abort it and do the
patch-splitting/cleanup/documentation work first so you can review
review the code better ASAP.

The advantage of doing it sooner is, it gets more of the testing that
is going on right now from you and everyone else, plus I dislike
leaving that important feature missing while many benchmarks are being
run, as it's going to certainly be measurable when the workload
changes massively and lots of hugepages are moved around by
knuma_migrated. Boosting khugepaged tends to hide it for now though
(as shown by specjbb).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
