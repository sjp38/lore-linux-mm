Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB466B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 05:54:03 -0400 (EDT)
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and
 'slabinfo'
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090817094822.GA17838@elte.hu>
References: <20090817094525.6355.88682.sendpatchset@localhost.localdomain>
	 <20090817094822.GA17838@elte.hu>
Date: Mon, 17 Aug 2009 12:54:07 +0300
Message-Id: <1250502847.5038.16.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-08-17 at 11:48 +0200, Ingo Molnar wrote:
> * Amerigo Wang <amwang@redhat.com> wrote:
> 
> > /proc/timer_list and /proc/slabinfo are not supposed to be 
> > written, so there should be no write permissions on it.
> 
> good catch!
> 
> > --- a/kernel/time/timer_list.c
> > +++ b/kernel/time/timer_list.c
> 
> I have applied the timer_list bits to the timer tree. The SLUB/SLAB 
> bits should go into the SLAB tree i guess.

Yeah, I'll grab the slab parts to slab.git if I don't see a separate
patch in my inbox when I get home. Thanks!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
