Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 6168B6B0069
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:53:22 -0400 (EDT)
Message-ID: <4FEDF963.9040700@redhat.com>
Date: Fri, 29 Jun 2012 14:52:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 19/40] autonuma: alloc/free/init sched_autonuma
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-20-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-20-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:55 AM, Andrea Arcangeli wrote:
> This is where the dynamically allocated sched_autonuma structure is
> being handled.
>
> The reason for keeping this outside of the task_struct besides not
> using too much kernel stack, is to only allocate it on NUMA
> hardware. So the not NUMA hardware only pays the memory of a pointer
> in the kernel stack (which remains NULL at all times in that case).

What is not documented is the reason for keeping it at all.

What is in the data structure?

What is the data structure used for?

How do we use it?

> +	if (unlikely(alloc_task_autonuma(tsk, orig, node)))
> +		/* free_thread_info() undoes arch_dup_task_struct() too */
> +		goto out_thread_info;

Oh, you mean task_autonuma, and not sched_autonuma?

Please fix the commit message and the subject.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
