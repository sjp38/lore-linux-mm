Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 30DF06B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 16:41:38 -0400 (EDT)
Received: by weys10 with SMTP id s10so4876208wey.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 13:41:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207301255320.24196@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2>
	<CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
	<alpine.DEB.2.00.1207301255320.24196@chino.kir.corp.google.com>
Date: Mon, 30 Jul 2012 23:41:35 +0300
Message-ID: <CAOJsxLHw8G0ChnOeBv1nNr3tqNPPjdnkY=RStyo3rRqC1bdDAA@mail.gmail.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: shuah.khan@hp.com, cl@linux.com, glommer@parallels.com, js1304@gmail.com, shuahkhan@gmail.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Jul 30, 2012 at 10:56 PM, David Rientjes <rientjes@google.com> wrote:
> -Wunused-label is overridden in gcc for a label that is conditionally
> referenced by using __maybe_unused in the kernel.  I'm not sure what's so
> obscure about
>
> out: __maybe_unused
>
> Are label attributes really that obsecure?

I think they are.

The real problem, however, is that label attributes would just paper
over the badly thought out control flow in the function and not make the
code any better or easier to read.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
