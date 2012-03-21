Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id DDB556B00FD
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 03:13:03 -0400 (EDT)
Received: by werj55 with SMTP id j55so912968wer.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 00:13:02 -0700 (PDT)
Date: Wed, 21 Mar 2012 08:12:58 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120321071258.GA24997@gmail.com>
References: <20120316144028.036474157@chello.nl>
 <20120316182511.GJ24602@redhat.com>
 <87k42edenh.fsf@danplanet.com>
 <20120321021239.GQ24602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120321021239.GQ24602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Andrea Arcangeli <aarcange@redhat.com> wrote:

> [...]
> 
> So give me a break... you must have made a real mess in your 
> benchmarking. numasched is always doing worse than upstream 
> here, in fact two times massively worse. Almost as bad as the 
> inverse binds.

Andrea, please stop attacking the messenger.

We wanted and needed more testing, and I'm glad that we got it.

Can we please figure out all the details *without* accusing 
anyone of having made a mess? It is quite possible as well that 
*you* made a mess of it somewhere, either at the conceptual 
stage or at the implementational stage, right?

numasched getting close to the hard binding numbers is pretty 
much what I'd expect to see from it: it is an 
automatic/intelligent CPU and memory affinity (and migration) 
method to approximate the results of manual hard binding of 
threads.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
