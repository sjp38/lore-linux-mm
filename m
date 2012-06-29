Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 2A3F66B0069
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:55:37 -0400 (EDT)
Message-ID: <4FEDF9D4.2080504@redhat.com>
Date: Fri, 29 Jun 2012 14:54:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 20/40] autonuma: alloc/free/init mm_autonuma
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-21-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-21-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:
> This is where the mm_autonuma structure is being handled. Just like
> sched_autonuma, this is only allocated at runtime if the hardware the
> kernel is running on has been detected as NUMA. On not NUMA hardware
> the memory cost is reduced to one pointer per mm.
>
> To get rid of the pointer in the each mm, the kernel can be compiled
> with CONFIG_AUTONUMA=n.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Same comments as before.  A description of what the data
structure is used for and how would be good.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
