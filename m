Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id B807D6B00E8
	for <linux-mm@kvack.org>; Thu, 10 May 2012 10:21:17 -0400 (EDT)
Date: Thu, 10 May 2012 09:21:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: BUG at mm/slub.c:374
In-Reply-To: <CAFLxGvymF0yo3k_j6EON-nk9=mQDaL72mnBxxJOv2awiWgjeYQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205100920250.18664@router.home>
References: <CAFLxGvy0PHZHVL9rZx_0oFGobKftPBc0EN3VEyzNqvg13FUEfw@mail.gmail.com> <alpine.DEB.2.00.1205090907070.8171@router.home> <CAFLxGvymF0yo3k_j6EON-nk9=mQDaL72mnBxxJOv2awiWgjeYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 10 May 2012, richard -rw- weinberger wrote:

> On Wed, May 9, 2012 at 4:14 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Wed, 9 May 2012, richard -rw- weinberger wrote:
> >
> >> A few minutes ago I saw this BUG within one of my KVM machines.
> >> Config is attached.
> >
> > Interrupts on in __cmpxchg_double_slab called from __slab_alloc? Does KVM
> > do some tricks with interrupt flags? I do not see how that can be
> > otherwise since __slab_alloc disables interrupts on entry and reenables on
> > exit.
>
> Dunno.
> So far I've seen this BUG only once. :-\

Hmmm... allocate_slab() does some dangerous games with the "flag" variable
which determines if interrupts are to be reenabled and disabled but I
cannot see how it could have the effect that you are seeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
