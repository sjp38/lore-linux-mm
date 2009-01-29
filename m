Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2C59B6B005C
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 15:02:40 -0500 (EST)
Date: Thu, 29 Jan 2009 21:02:29 +0100 (CET)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions
In-Reply-To: <20090127174158.519e5abd.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0901292101430.17617@anakin>
References: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
 <20090127174158.519e5abd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Righi <righi.andrea@gmail.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jan 2009, Andrew Morton wrote:
> On Sun, 25 Jan 2009 22:35:37 +0100
> Andrea Righi <righi.andrea@gmail.com> wrote:
> 
> > diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
> > index a7cdc48..b132d69 100644
> > --- a/include/asm-generic/pgtable-nopmd.h
> > +++ b/include/asm-generic/pgtable-nopmd.h
> > @@ -4,6 +4,7 @@
> >  #ifndef __ASSEMBLY__
> >  
> >  #include <asm-generic/pgtable-nopud.h>
> > +#include <asm/bug.h>
> >  
> >  struct mm_struct;
> >  
> 
> Why not include the preferred <linux/bug.h>?
> 
> > BTW, I only tested this on x86 and x86_64. This needs more testing because it
> > touches also a lot of other architectures.
> 
> Hopefully Geert, Roman, David and Hirokazu Takata will have time to
> help out here.

atari_defconfig builds fine and boots on ARAnyM.

sun3_defconfig fails with:

|   CC      mm/memory.o
| mm/memory.c: In function 'free_pmd_range':
| mm/memory.c:176: error: implicit declaration of function '__pmd_free_tlb'
| mm/memory.c: In function '__pmd_alloc':
| mm/memory.c:2903: error: implicit declaration of function 'pmd_alloc_one_bug'
| mm/memory.c:2903: warning: initialization makes pointer from integer without a cast
| mm/memory.c:2917: error: implicit declaration of function 'pmd_free'
| make[3]: *** [mm/memory.o] Error 1

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
