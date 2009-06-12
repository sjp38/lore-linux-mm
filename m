Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACCED6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:04:14 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1244815370.7172.169.camel@pasglop>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <1244796045.7172.82.camel@pasglop>
	 <1244796211.30512.32.camel@penberg-laptop>
	 <1244796837.7172.95.camel@pasglop>
	 <1244797659.30512.37.camel@penberg-laptop>
	 <alpine.DEB.1.10.0906120944540.15809@gentwo.org>
	 <1244814852.30512.67.camel@penberg-laptop>
	 <1244815370.7172.169.camel@pasglop>
Date: Fri, 12 Jun 2009 17:04:17 +0300
Message-Id: <1244815457.30512.68.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Sat, 2009-06-13 at 00:02 +1000, Benjamin Herrenschmidt wrote:
> On Fri, 2009-06-12 at 16:54 +0300, Pekka Enberg wrote:
> > Hi Christoph,
> > 
> > On Fri, 2009-06-12 at 09:49 -0400, Christoph Lameter wrote:
> > > Best thing to do is to recognize the fact that we are still in early boot
> > > in the allocators. Derived allocators (such as slab and vmalloc) mask bits
> > > using GFP_RECLAIM_MASK and when doing allocations through the page
> > > allocator. You could make GFP_RECLAIM_MASK a variable. During boot
> > > __GFP_WAIT would not be set in GFP_RECLAIM_MASK.
> > 
> > Ben's patch does something like that and I have patches that do that
> > floating around too.
> > 
> > The problem here is that it's not enough that we make GFP_RECLAIM_MASK a
> > variable. There are various _debugging checks_ that happen much earlier
> > than that. We need to mask out those too which adds overhead to
> > kmalloc() fastpath, for example.
> 
> Hrm... I though I stuck my masking before the lockdep tests but maybe I
> missed some...

Your patch is fine but what Christoph suggested is not (at least the way
I understood it).

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
