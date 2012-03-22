Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id E1D6C6B007E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 09:58:32 -0400 (EDT)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [RFC] AutoNUMA alpha6
References: <20120316144028.036474157@chello.nl>
	<20120316182511.GJ24602@redhat.com> <87k42edenh.fsf@danplanet.com>
	<20120321021239.GQ24602@redhat.com> <87fwd2d2kp.fsf@danplanet.com>
	<20120321124937.GX24602@redhat.com> <87limtboet.fsf@danplanet.com>
	<20120321225242.GL24602@redhat.com>
	<20120322001722.GQ24602@redhat.com>
Date: Thu, 22 Mar 2012 06:58:29 -0700
In-Reply-To: <20120322001722.GQ24602@redhat.com> (Andrea Arcangeli's message
	of "Thu, 22 Mar 2012 01:17:22 +0100")
Message-ID: <873990buuy.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

AA> The only reasonable explanation I can imagine for the weird stuff
AA> going on with "numa01_inverse" is that maybe it was compiled without
AA> -DHARD_BIND? I forgot to specify -DINVERSE_BIND is a noop unless
AA> -DHARD_BIND is specified too at the same time. -DINVERSE_BIND alone
AA> results in the default build without -D parameters.

Ah, yeah, that's probably it. Later I'll try re-running some of the
cases to verify.

-- 
Dan Smith
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
