Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 2CC626B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 22:07:24 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so12280817pbb.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 19:07:23 -0700 (PDT)
Date: Mon, 30 Jul 2012 19:07:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <CAOJsxLHw8G0ChnOeBv1nNr3tqNPPjdnkY=RStyo3rRqC1bdDAA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207301904520.24929@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2> <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com> <alpine.DEB.2.00.1207301255320.24196@chino.kir.corp.google.com> <CAOJsxLHw8G0ChnOeBv1nNr3tqNPPjdnkY=RStyo3rRqC1bdDAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: shuah.khan@hp.com, cl@linux.com, glommer@parallels.com, js1304@gmail.com, shuahkhan@gmail.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 30 Jul 2012, Pekka Enberg wrote:

> > -Wunused-label is overridden in gcc for a label that is conditionally
> > referenced by using __maybe_unused in the kernel.  I'm not sure what's so
> > obscure about
> >
> > out: __maybe_unused
> >
> > Are label attributes really that obsecure?
> 
> I think they are.
> 
> The real problem, however, is that label attributes would just paper
> over the badly thought out control flow in the function and not make the
> code any better or easier to read.
> 

So much for compromise, I thought we had agreed that at least some of the 
checks for !name, in_interrupt() or bad size values should be moved out 
from under the #ifdef CONFIG_DEBUG_VM, but this wasn't done.  This 
discussion would be irrelevent if we actually did what we talked about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
