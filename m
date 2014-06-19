Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 86F276B003B
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:42:19 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so2195645pdj.1
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:42:19 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ko1si7031308pbc.100.2014.06.19.13.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 13:42:18 -0700 (PDT)
Message-ID: <53A34B23.1000401@oracle.com>
Date: Thu, 19 Jun 2014 16:42:11 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: slub/debugobjects: lockup when freeing memory
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192127100.5170@nanos> <20140619202928.GG4904@linux.vnet.ibm.com>
In-Reply-To: <20140619202928.GG4904@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/19/2014 04:29 PM, Paul E. McKenney wrote:
> rcu: Provide call_rcu_alloc() and call_rcu_sched_alloc() to avoid recursion
> 
> The sl*b allocators use call_rcu() to manage object lifetimes, but
> call_rcu() can use debug-objects, which in turn invokes the sl*b
> allocators.  These allocators are not prepared for this sort of
> recursion, which can result in failures.
> 
> This commit therefore creates call_rcu_alloc() and call_rcu_sched_alloc(),
> which act as their call_rcu() and call_rcu_sched() counterparts, but
> which avoid invoking debug-objects.  These new API members are intended
> only for use by the sl*b allocators, and this commit makes the sl*b
> allocators use call_rcu_alloc().  Why call_rcu_sched_alloc()?  Because
> in CONFIG_PREEMPT=n kernels, call_rcu() maps to call_rcu_sched(), so
> therefore call_rcu_alloc() must map to call_rcu_sched_alloc().
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Set-straight-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Paul, what is this patch based on? It won't apply cleanly on -next
or Linus's tree.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
