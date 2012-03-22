Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 35F636B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 06:34:27 -0400 (EDT)
Received: by werj55 with SMTP id j55so2264391wer.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 03:34:25 -0700 (PDT)
Date: Thu, 22 Mar 2012 11:34:20 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120322103420.GA32716@gmail.com>
References: <20120316144028.036474157@chello.nl>
 <CAOhV88NafiU7hseTzQfApthMk3X=_GT09gEM2Zzx5OJ=8z6vvw@mail.gmail.com>
 <1332409539.18960.508.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1332409539.18960.508.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nish Aravamudan <nish.aravamudan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> 
> > I was going to try and test this on power, but it fails to build:
> > 
> >   mm/filemap_xip.c: In function a??__xip_unmapa??:
> >   mm/filemap_xip.c:199: error: implicit declaration of function
> > a??numa_add_vma_countera??
> 
> Add: 
> 
> #include <linux/mempolicy.h>
> 
> to that file and it should build.

I could stick your patches into tip:sched/numa (rebasing branch 
for now) to make it pullable and testable?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
