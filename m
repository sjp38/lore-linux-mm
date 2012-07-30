Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id CD73C6B005D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:56:38 -0400 (EDT)
Received: by yenr5 with SMTP id r5so6239978yen.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 12:56:37 -0700 (PDT)
Date: Mon, 30 Jul 2012 12:56:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207301255320.24196@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2> <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-769099234-1343678195=:24196"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: shuah.khan@hp.com, cl@linux.com, glommer@parallels.com, js1304@gmail.com, shuahkhan@gmail.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-769099234-1343678195=:24196
Content-Type: TEXT/PLAIN; charset=windows-1252
Content-Transfer-Encoding: 8BIT

On Mon, 30 Jul 2012, Pekka Enberg wrote:

> > The label oops is used in CONFIG_DEBUG_VM ifdef block and is defined
> > outside ifdef CONFIG_DEBUG_VM block. This results in the following
> > build warning when built with CONFIG_DEBUG_VM disabled. Fix to move
> > label oops definition to inside a CONFIG_DEBUG_VM block.
> >
> > mm/slab_common.c: In function ?kmem_cache_create?:
> > mm/slab_common.c:101:1: warning: label ?oops? defined but not used
> > [-Wunused-label]
> >
> > Signed-off-by: Shuah Khan <shuah.khan@hp.com>
> 
> I merged this as an obvious and safe fix for current merge window. We
> need to clean this up properly for v3.7.
> 

-Wunused-label is overridden in gcc for a label that is conditionally 
referenced by using __maybe_unused in the kernel.  I'm not sure what's so 
obscure about

out: __maybe_unused

Are label attributes really that obsecure?
--397155492-769099234-1343678195=:24196--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
