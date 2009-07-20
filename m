Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9673D6B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 03:48:23 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.14.3/8.13.8) with ESMTP id n6K7mLkQ110008
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 07:48:21 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6K7mLew2514962
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:48:21 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6K7mK4n006521
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:48:20 +0200
Date: Mon, 20 Jul 2009 09:48:18 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC/PATCH] mm: Pass virtual address to
 [__]p{te,ud,md}_free_tlb()
Message-ID: <20090720094818.641e6375@skybase>
In-Reply-To: <1248073873.13067.31.camel@pasglop>
References: <20090715074952.A36C7DDDB2@ozlabs.org>
	<20090715135620.GD7298@wotan.suse.de>
	<1248073873.13067.31.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Jul 2009 17:11:13 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Wed, 2009-07-15 at 15:56 +0200, Nick Piggin wrote:
> > > I would like to merge the new support that depends on this in 2.6.32,
> > > so unless there's major objections, I'd like this to go in early during
> > > the merge window. We can sort out separately how to carry the patch
> > > around in -next until then since the powerpc tree will have a dependency
> > > on it.
> > 
> > Can't see any problem with that.
> 
> CC'ing Linus here. How do you want to proceed with that merge ? (IE. so
> far nobody objected to the patch itself)
> 
> IE. The patch affects all archs, though it's a trivial change every
> time, but I'll have stuff in powerpc-next that depends on it, and so I'm
> not sure what the right approach is here. Should I put it in the powerpc
> tree ?
> 
> I also didn't have any formal Ack from anybody, neither mm folks nor
> arch maintainers :-)

Well the change is trivial, it just adds another unused argument to the
macros. For the records: it still compiles on s390.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
