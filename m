Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE9F6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:23:46 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090612091304.GE24044@wotan.suse.de>
References: <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <20090612075427.GA24044@wotan.suse.de>
	 <1244793592.30512.17.camel@penberg-laptop>
	 <20090612080236.GB24044@wotan.suse.de>
	 <1244793879.30512.19.camel@penberg-laptop>
	 <1244796291.7172.87.camel@pasglop>
	 <84144f020906120149k6cbe5177vef1944d9d216e8b2@mail.gmail.com>
	 <20090612091304.GE24044@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 19:24:20 +1000
Message-Id: <1244798660.7172.102.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


> It's OK. I'd make it gfp_notsmellybits, and avoid the ~.
> And read_mostly.

read_mostly is fine. gfp_notsmellybits isn't a nice name :-) Make it
gfp_allowedbits then. I did it backward on purpose though as the risk of
"missing" bits here (as we may add new ones) is higher and it seemed to
me generally simpler to just explicit spell out the ones to forbid
(also, on powerpc,  &~ is one instruction :-)
 
> Probably would be better to hide it in mm/ and then just
> allow it to be modified with a couple of calls. OTOH if
> it is only modified in a couple of places then maybe that's
> overkill.

It might indeed be nicer to hide it behind an accessor.

> The whole problem comes about because we don't just restore
> our previously saved flags here... I guess it probably adds
> even more overhead to do that and make everything just work :(

Well... that's part of the equation. My solution has the advantage to
also providing ground to forbid GFP_IO during suspend/resume etc...

Cheers,
Ben.

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
