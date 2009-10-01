Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD7F6006D0
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 14:32:25 -0400 (EDT)
Date: Thu, 1 Oct 2009 21:17:03 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [this_cpu_xx V3 11/19] RCU: Use this_cpu operations
Message-ID: <20091001191703.GC24158@elte.hu>
References: <20091001174033.576397715@gentwo.org> <20091001174121.651756642@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091001174121.651756642@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>


* cl@linux-foundation.org <cl@linux-foundation.org> wrote:

> RCU does not do dynamic allocations but it increments per cpu variables
> a lot. These instructions results in a move to a register and then back
> to memory. This patch will make it use the inc/dec instructions on x86
> that do not need a register.
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  kernel/rcutorture.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

_PLEASE_ Cc: all these this_cpu patches to lkml in the future, all the 
time. It's obviously interesting on a core kernel level and shouldnt be 
sent to linux-mm alone.

Thanks a ton,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
