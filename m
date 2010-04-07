Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C03376B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 04:56:24 -0400 (EDT)
Subject: Re: Arch specific mmap attributes (Was: mprotect pgprot handling
 weirdness)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100407095145.FB70.A69D9226@jp.fujitsu.com>
References: <20100406185246.7E63.A69D9226@jp.fujitsu.com>
	 <1270592111.13812.88.camel@pasglop>
	 <20100407095145.FB70.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Apr 2010 18:56:13 +1000
Message-ID: <1270630573.2300.90.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-04-07 at 15:03 +0900, KOSAKI Motohiro wrote:

> Generally speaking, It seems no good idea. desktop and server world don't
> interest arch specific mmu attribute crap.

So you are saying that because your desktop and servers don't care Linux
shouldn't support the possiblity ? IE. Embedded doesn't matter or some
sort of similar statement ? :-) Come on ...

Anyways, this is just not true. Take SAO, this is a server feature (used
among others for x86 emulation). Little Endian mappings is indeed more
of an "embedded" feature to some extent, at least the way we plan to use
it, but is still very relevant.

Caching attributes control and storage keys can be useful in a lot of
other areas that really have nothing to do with HPC :-) Databases come
to mind, there's more too.

In any case, I don't know why you argue. We have features that a lot of
the CPUs out there provide, that at least some people out there would
like to exploit, and you are saying that Linux should not provide
support for these because your vision of a desktop/server only world is
all that matters ?

Anyways, let's go back to -how- to implement that properly rather than
that sort of reasonably useless argument.

> because many many opensource
> and ISV library don't care it. I know highend hpc and embedded have 
> differenct eco-system. they might want to use such strange mmu feature.
> I recommend to you are focusing popwerpc eco-system. 

Thanks you for your recommendation :-)

> I'm not against changing kernel internal. I only disagree mmu attribute
> fashion will be become used widely.

So how do you propose we proceed ? Extend vm_flags to be a u64 instead ?

I don't really care much which method is used, though from a -technical-
perspective, the mmu attributes one seem to be nicer in the long run,
but my immediate needs would be well served by just adding 2 or 3 flags
in there :-)

In any case, I'd be curious to have Hugh and Nick opinions here on the
technicalities.

Cheers,
Ben.

> > Some powerpc's also provide storage keys for example and I think ARM
> > have something along those lines. There's interesting cachability
> > attributes too, on x86 as well. Being able to use such attributes to
> > request for example a relaxed ordering mapping on x86 might be useful.
> > 
> > I think it basically boils down to either extend vm_flags to always be
> > 64-bit, which seems to be Nick preferred approach, or introduct a
> > vm_attributes with all the necessary changes to the merge code to take
> > it into account (not -that- hard tho, there's only half a page of
> > results in grep for these things :-)
> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
