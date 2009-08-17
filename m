Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C8D696B005C
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 05:48:25 -0400 (EDT)
Date: Mon, 17 Aug 2009 11:48:22 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and
	'slabinfo'
Message-ID: <20090817094822.GA17838@elte.hu>
References: <20090817094525.6355.88682.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090817094525.6355.88682.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>


* Amerigo Wang <amwang@redhat.com> wrote:

> /proc/timer_list and /proc/slabinfo are not supposed to be 
> written, so there should be no write permissions on it.

good catch!

> --- a/kernel/time/timer_list.c
> +++ b/kernel/time/timer_list.c

I have applied the timer_list bits to the timer tree. The SLUB/SLAB 
bits should go into the SLAB tree i guess.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
