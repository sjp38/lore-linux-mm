Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2C86B0082
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:42:14 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1244796045.7172.82.camel@pasglop>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <1244796045.7172.82.camel@pasglop>
Date: Fri, 12 Jun 2009 11:43:31 +0300
Message-Id: <1244796211.30512.32.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Fri, 2009-06-12 at 18:40 +1000, Benjamin Herrenschmidt wrote:
> On Fri, 2009-06-12 at 10:45 +0300, Pekka Enberg wrote:
> > Hi Ben,
> 
> > The call-sites I fixed up are all boot code AFAICT. And I like I said,
> > we can't really _miss_ any of those places, they must be checking for
> > slab_is_available() _anyway_; otherwise they have no business using
> > kmalloc(). And note: all call-sites that _unconditionally_ use
> > kmalloc(GFP_KERNEL) are safe because they worked before.
> 
> No. The check for slab_is_available() can be levels higher, for example
> the vmalloc case. I'm sure I can find a whole bunch more :-) Besides
> I find the approach fragile, and it will suck for things that can be
> rightfully called also later on.

Yes, you're obviously right. I overlooked the fact that arch code have
their own special slab_is_available() heuristics (yikes!).

But are you happy with the two patches I posted so I can push them to
Linus?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
