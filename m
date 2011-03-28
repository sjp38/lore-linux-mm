Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E4A4E8D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 02:37:07 -0400 (EDT)
Date: Mon, 28 Mar 2011 08:36:56 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] slub: Disable the lockless allocator
Message-ID: <20110328063656.GA29462@elte.hu>
References: <1301161507.2979.105.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103261406420.24195@router.home>
 <alpine.DEB.2.00.1103261428200.25375@router.home>
 <alpine.DEB.2.00.1103261440160.25375@router.home>
 <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
 <alpine.DEB.2.00.1103262028170.1004@router.home>
 <alpine.DEB.2.00.1103262054410.1373@router.home>
 <4D9026C8.6060905@cs.helsinki.fi>
 <20110328061929.GA24328@elte.hu>
 <AANLkTinpCa6GBjP3+fdantvOdbktqW8m_D0fGkAnCXYk@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinpCa6GBjP3+fdantvOdbktqW8m_D0fGkAnCXYk@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Pekka Enberg <penberg@kernel.org> wrote:

> On Mon, Mar 28, 2011 at 9:19 AM, Ingo Molnar <mingo@elte.hu> wrote:
> >> Tejun, does this look good to you as well? I think it should go
> >> through the percpu tree. It's needed to fix a boot crash with
> >> lockless SLUB fastpaths enabled.
> >
> > AFAICS Linus applied it already:
> >
> > d7c3f8cee81f: percpu: Omit segment prefix in the UP case for cmpxchg_double
> 
> Oh, I missed that. Did you test the patch, Ingo? It's missing attributions 
> and reference to the LKML discussion unfortunately...

I think we might still be missing the hunk below - or is it now not needed 
anymore?

Thanks,

	Ingo

-------------->
