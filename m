Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0946B6B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:35:34 -0400 (EDT)
Message-ID: <4A8986BB.80409@cs.helsinki.fi>
Date: Mon, 17 Aug 2009 19:35:07 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and 'slabinfo'
References: <20090817094525.6355.88682.sendpatchset@localhost.localdomain>  <20090817094822.GA17838@elte.hu> <1250502847.5038.16.camel@penberg-laptop> <alpine.DEB.1.10.0908171228300.16267@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0908171228300.16267@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Christoph Lameter wrote:
> On Mon, 17 Aug 2009, Pekka Enberg wrote:
> 
>>> I have applied the timer_list bits to the timer tree. The SLUB/SLAB
>>> bits should go into the SLAB tree i guess.
>> Yeah, I'll grab the slab parts to slab.git if I don't see a separate
>> patch in my inbox when I get home. Thanks!
> 
> slab needs the write permissions for tuning!

Oh, crap, you're right, I had forgotten about that. It's probably best 
to keep slub permissions as-is, no?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
