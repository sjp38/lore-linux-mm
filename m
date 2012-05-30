Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 7EFD76B0071
	for <linux-mm@kvack.org>; Wed, 30 May 2012 11:30:42 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so6099791bkc.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 08:30:40 -0700 (PDT)
Date: Wed, 30 May 2012 17:30:34 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
Message-ID: <20120530153034.GB4341@gmail.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <4FC112AB.1040605@redhat.com>
 <CA+55aFxpD+LsE+aNvDJtz9sGsGMvdusisgOY3Csbzyx1mEqW-w@mail.gmail.com>
 <1338389200.26856.273.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338389200.26856.273.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> So the thing is, my homenode-per-process approach should work 
> for everything except the case where a single process 
> out-strips a single node in either cpu utilization or memory 
> consumption.
> 
> Now I claim such processes are rare since nodes are big, 
> typically 6-8 cores. Writing anything that can sustain 
> parallel execution larger than that is very specialist (and 
> typically already employs strong data separation).
> 
> Yes there are such things out there, some use JVMs some are 
> virtual machines some regular applications, but by and large 
> processes are small compared to nodes.
> 
> So my approach is focus on the normal case, and provide 2 
> system calls to replace sched_setaffinity() and mbind() for 
> the people who use those.

We could certainly strike those from the first version, if Linus 
agrees with the general approach.

This gives us degrees freedom as it's an obvious on/off kernel 
feature which we fix or remove if it does not work.

I'd even venture that it should be on by default, it's an 
obvious placement strategy for everything sane that does not try 
to nest some other execution environment within Linux (i.e. 
specialist runtimes).

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
