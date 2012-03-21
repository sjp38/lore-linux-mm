Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 16EC66B004D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 13:08:35 -0400 (EDT)
Date: Wed, 21 Mar 2012 17:50:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120321165030.GC24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
 <20120319130401.GI24602@redhat.com>
 <1332163591.18960.334.camel@twins>
 <20120319135745.GL24602@redhat.com>
 <4F673D73.90106@redhat.com>
 <20120319143002.GQ24602@redhat.com>
 <1332182523.18960.372.camel@twins>
 <4F69022D.3080300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F69022D.3080300@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue, Mar 20, 2012 at 06:18:21PM -0400, Rik van Riel wrote:
> Getting high level documentation of the ideas behind both
> of the NUMA implementations could really help smooth out
> the debate.

If I didn't explain it in detail so far, has been because of lack of
time. Plus nobody asked specific questions on the internals yet. And I
do my best to avoid writing books through email even if I fail at that
sometime.

I wanted do a few more code changes to make it faster first (like
badly needed THP migration).

For sure, I'll prepare some initial highlevel documentation on the
AutoNUMA algorithms for the MM summit (the resulting pdf I will
publish it of course), in addition to more benchmark data.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
