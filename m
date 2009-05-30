Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B51C55F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 18:14:46 -0400 (EDT)
Date: Sun, 31 May 2009 00:14:44 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530221444.GB23204@elte.hu>
References: <20090528072702.796622b6@lxorguk.ukuu.org.uk> <20090528090836.GB6715@elte.hu> <20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com> <20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi> <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <84144f020905301322g7bbdd42cpe1391c619ffda044@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020905301322g7bbdd42cpe1391c619ffda044@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Larry H." <research@subreption.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Hi Larry,
> 
> On Sat, May 30, 2009 at 9:03 PM, Larry H. <research@subreption.com> wrote:
> > The first issue is that SLOB has a broken ksize, which won't take into
> > consideration compound pages AFAIK. To fix this you will need to
> > introduce some changes in the way the slob_page structure is handled,
> > and add real size tracking to it. You will find these problems if you
> > try to implement a reliable kmem_ptr_validate for SLOB, too.
> 
> Does this mean that kzfree() isn't broken for SLAB/SLUB? Maybe I 
> read your emails wrong but you seemed to imply that.

Yep, he definitely wrote that:

    http://lkml.org/lkml/2009/5/30/30

 [...]
 |
 | That's hopeless, and kzfree is broken. Like I said in my earlier 
 | reply, please test that yourself to see the results. Whoever 
 | wrote that ignored how SLAB/SLUB work and if kzfree had been used 
 | somewhere in the kernel before, it should have been noticed long 
 | time ago.
 |
 [...]

Very puzzling claims i have to say.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
