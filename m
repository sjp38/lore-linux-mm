Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 836546B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 10:17:36 -0400 (EDT)
Date: Mon, 19 Mar 2012 15:16:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120319141647.GN24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
 <20120319130401.GI24602@redhat.com>
 <1332163594.18960.335.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332163594.18960.335.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 02:26:34PM +0100, Peter Zijlstra wrote:
> So what about the case where all I do is compile kernels and we already
> have near perfect locality because everything is short running? You're
> still scanning that memory, and I get no benefit.

I could add an option to delay the scan and enable it only on long
lived "mm". In practice I measured the scanning cost and it was in the
unmeasurable range on host this is why I didn't yet, plus I tried to
avoid all special cases and to keep things as generic as possible so
treating everything the same. Maybe it's good idea, maybe not as it
delays more the time it takes to react to wrong memory layout.

If you stop knuma_scand with sysfs (echo 0 >...) the whole thing
eventually stops. It's like 3 gears, where first gear is knuma_scand,
second gear is the numa hinting page fault, the third gears are
knuma_migrated and CPU scheduler that gets driven.

So it's easy to benchmark the fixed cost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
