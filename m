Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id CB6966B0044
	for <linux-mm@kvack.org>; Sun, 25 Mar 2012 09:31:02 -0400 (EDT)
Date: Sun, 25 Mar 2012 15:30:27 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120325133027.GG5906@redhat.com>
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
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>

On Thu, Mar 22, 2012 at 11:56:37AM -0700, Dan Smith wrote:
> I dunno about everyone else, but I think the thing I'd like to see most
> (other than more interesting benchmarks) is a broken out and documented
> set of patches instead of the monolithic commit you have now. I know you
> weren't probably planning to do that until numasched came along, but it
> sure would help me digest the differences in the two approaches.

Ok this is a start. I'll have to review it again tomorrow and add more
docs before I can do proper submit by email. If you're willing to
contribute you can review it already using "git format-patch 9ca11f1"
after fetching the repo. Comments welcome!

git clone --reference linux -b autonuma-dev-smt git://git.kernel.org/pub/scm/linux/kernel/git/andaa.git

The last patch in that branch is the last feature I worked on
yesterday and it fixes the SMT load with numa02.c modified to use only
1 thread per core, which means changing THREADS from 24 to 12 in the
numa02.c source at the top (and then building it again in the
-DHARD_BIND and -DHARD_BIND -DINVERSE_BIND versions to compare with
autonuma on and off). It also fixes building the kernel in a loop in
KVM with 12 vcpus (now the load spreads over the two nodes). echo 0
>/sys/kernel/mm/autonuma/scheduler/smt would disable the SMT
awareness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
