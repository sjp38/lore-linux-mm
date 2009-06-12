Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F39526B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:07:29 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1244796837.7172.95.camel@pasglop>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <1244796045.7172.82.camel@pasglop>
	 <1244796211.30512.32.camel@penberg-laptop>
	 <1244796837.7172.95.camel@pasglop>
Date: Fri, 12 Jun 2009 12:07:39 +0300
Message-Id: <1244797659.30512.37.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Fri, 2009-06-12 at 18:53 +1000, Benjamin Herrenschmidt wrote:
> > Yes, you're obviously right. I overlooked the fact that arch code have
> > their own special slab_is_available() heuristics (yikes!).
> > 
> > But are you happy with the two patches I posted so I can push them to
> > Linus?
> 
> I won't be able to test them until tomorrow. However, I think the first
> one becomes unnecessary with the second one applied (provided you didn't
> miss a case), no ?

OK, I am dropping the slub/slab patch from the queue for now. Here's
what I am going to push to Linus:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=shortlog;h=topic/slab/earlyboot

So I am sending the GFP_NOWAIT conversion for boot code even though you
didn't seem to like it (but didn't explicitly NAK) as it fixes problems
on x86.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
