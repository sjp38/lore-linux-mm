Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 58B576B0062
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 00:37:11 -0400 (EDT)
Date: Thu, 25 Jun 2009 06:38:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
Message-ID: <20090625043818.GB23949@wotan.suse.de>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090612091002.GA32052@elte.hu> <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com> <20090612095206.GA13607@wotan.suse.de> <1244800774.7172.116.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244800774.7172.116.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 07:59:34PM +1000, Benjamin Herrenschmidt wrote:
> 
> > Maybe if we just not make it a general "tweak gfpflag" bit (at
> > least not until a bit more discussion), but a specific workaround
> > for the local_irq_enable in early boot problem.
> > 
> > Seems like it would not be hard to track things down if we add
> > a warning if we have GFP_WAIT and interrupts are not enabled...
> 
> But tweaking local_irq_enable() will have a lot more performance & bloat
> impact overall on the normal case.

(sorry for the late replies. I've been sick and missed a few
things over the past week or two... not that this is a really
urgent issue ;))

I was not proposing to put a branch in local_irq_enable ;)
but to use local_irq_save/restore in the slab allocators rather
than unconditional.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
