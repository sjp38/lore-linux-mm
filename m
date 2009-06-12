Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 148B26B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:53:06 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090612095206.GA13607@wotan.suse.de>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612095206.GA13607@wotan.suse.de>
Date: Fri, 12 Jun 2009 12:54:44 +0300
Message-Id: <1244800484.30512.39.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 11:52 +0200, Nick Piggin wrote:
> Maybe if we just not make it a general "tweak gfpflag" bit (at
> least not until a bit more discussion), but a specific workaround
> for the local_irq_enable in early boot problem.
> 
> Seems like it would not be hard to track things down if we add
> a warning if we have GFP_WAIT and interrupts are not enabled...

AFAICT, the point is that Ben thinks that we shouldn't go and try to fix
up all the callers. But yes, we could certainly do that too.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
