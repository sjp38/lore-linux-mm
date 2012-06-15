Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id F21406B0069
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 14:16:00 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5355357dak.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 11:16:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120316144240.889278872@chello.nl>
References: <20120316144028.036474157@chello.nl>
	<20120316144240.889278872@chello.nl>
Date: Fri, 15 Jun 2012 11:16:00 -0700
Message-ID: <CA+8MBbJVFdz0g9dqz+3YbsGypKw4-tLb2XgoFq=_qOoq_Yq=Tw@mail.gmail.com>
Subject: Re: [RFC][PATCH 12/26] sched, mm: sched_{fork,exec} node assignment
From: Tony Luck <tony.luck@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 16, 2012 at 7:40 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
> Rework the scheduler fork,exec hooks to allow home-node assignment.

Some compile errors on the (somewhat bizarre) CONFIG_SMP=3Dn,
CONFIG_NUMA=3Dy case:

> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> +
> + =A0 =A0 =A0 select_task_node(p, p->mm, SD_BALANCE_FORK);
kernel/sched/core.c: In function =91sched_fork=92:
kernel/sched/core.c:1802: error: =91SD_BALANCE_FORK=92 undeclared (first
use in this function)

Also (from an earlier patch?)

In file included from kernel/sched/core.c:84:
kernel/sched/sched.h: In function =91offnode_tasks=92:
kernel/sched/sched.h:477: error: =91struct rq=92 has no member named =91off=
node_tasks=92

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
