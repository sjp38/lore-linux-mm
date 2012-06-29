Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id AC2596B0073
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:37:00 -0400 (EDT)
Message-ID: <4FEDCB7A.1060007@redhat.com>
Date: Fri, 29 Jun 2012 11:36:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/40] autonuma: introduce kthread_bind_node()
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-10-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:

> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1792,7 +1792,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>   #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
>   #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
>   #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
> -#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpu */
> +#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpus */
>   #define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
>   #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
>   #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */

Changing the semantics of PF_THREAD_BOUND without so much as
a comment in your changelog or buy-in from the scheduler
maintainers is a big no-no.

Is there any reason you even need PF_THREAD_BOUND in your
kernel numa threads?

I do not see much at all in the scheduler code that uses
PF_THREAD_BOUND and it is not clear at all that your
numa threads get any benefit from them...

Why do you think you need it?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
