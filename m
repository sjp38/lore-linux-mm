Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A2B86B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 15:32:51 -0400 (EDT)
Date: Tue, 17 Aug 2010 14:32:48 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q3 20/23] slub: Shared cache to exploit cross cpu caching
 abilities.
In-Reply-To: <alpine.DEB.2.00.1008171158530.21770@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1008171431590.14588@router.home>
References: <20100804024514.139976032@linux.com> <20100804024535.338543724@linux.com> <alpine.DEB.2.00.1008162246500.26781@chino.kir.corp.google.com> <alpine.DEB.2.00.1008171234130.12188@router.home> <alpine.DEB.2.00.1008171137030.6486@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1008171348220.13665@router.home> <alpine.DEB.2.00.1008171158530.21770@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, David Rientjes wrote:

> On Tue, 17 Aug 2010, Christoph Lameter wrote:
>
> > Well yes I guess that is the result of large scale corruption that is
> > reaching into the debug fields of the object.
> >
> > > [   15.752467]
> > > [   15.752467] INFO: 0xffff880c7e5f3ec0-0xffff880c7e5f3ec7. First byte 0x30 instead of 0xbb
> > > [   15.752467] INFO: Allocated in 0xffff88087e4f11e0 age=131909211166235 cpu=2119111312 pid=-30712
> > > [   15.752467] INFO: Freed in 0xffff88087e4f13f0 age=131909211165707 cpu=2119111840 pid=-30712
> > > [   15.752467] INFO: Slab 0xffffea002bba4d28 objects=51 new=3 fp=0x0007000000000000 flags=0xa00000000000080
> > > [   15.752467] INFO: Object 0xffff880c7e5f3eb0 @offset=3760
> > > [   15.752467]
> > > [   15.752467] Bytes b4 0xffff880c7e5f3ea0:  18 00 00 00 7e 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ....~...ZZZZZZZZ
> > > [   15.752467]   Object 0xffff880c7e5f3eb0:  d0 0f 4f 7e 08 88 ff ff 80 10 4f 7e 08 88 ff ff .O~....O~..
> > > [   15.752467]  Redzone 0xffff880c7e5f3ec0:  30 11 4f 7e 08 88 ff ff                         0.O~..
> > > [   15.752467]  Padding 0xffff880c7e5f3ef8:  00 16 4f 7e 08 88 ff ff                         ..O~..
> >
> > 16 bytes allocated and a pointer array much larger than that is used.
> >
>
> Since the problem persists with and without CONFIG_SLUB_DEBUG_ON, I'd
> speculate that this is a problem with node scalability on my 4-node system
> if this boots fine for you.

Looking at it. I have a fakenuma setup here that does not trigger it.
Guess I need something more real.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
