Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9723E6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:39:18 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH][RFC] mm: uncached vma support with writenotify
Date: Tue, 23 Jun 2009 14:40:11 +0200
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <20090615033240.GC31902@linux-sh.org> <20090622151537.2f8009f7.akpm@linux-foundation.org>
In-Reply-To: <20090622151537.2f8009f7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200906231440.11590.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, magnus.damm@gmail.com, arnd@arndb.de, linux-mm@kvack.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Tuesday 23 June 2009, you wrote:

> > I guess the only real issue here is that we presently have no generic
> > interface in the kernel for setting a VMA uncached. pgprot_noncached()
> > is the closest approximation we have, but there are still architectures
> > that do not implement it.
> > 
> > Given that this comes up at least once a month, perhaps it makes sense to
> > see which platforms are still outstanding. At least cris, h8300,
> > m68knommu, s390, and xtensa all presently lack a definition for it. The
> > nommu cases are easily handled, but the rest still require some attention
> > from their architecture maintainers before we can really start treating
> > this as a generic interface.

For m68knommu, h8300 and s390, doing nothing is correct because they
either don't have page tables or don't control caching through them.
Xtensa could easily add it, they have the respective caching strategy
in their page flags. On cris, caching is controlled through the high
bit of the address, but I guess that means we could just add
'#define _PAGE_UNCACHED  (1 << 31)' there and set that for uncached.

> > which works fine for the nommu case, and which functionally is no
> > different from what happens right now anyways for the users that don't
> > wire it up sanely.
> > 
> > Arnd, what do you think about throwing this at asm-generic?
> > 
> 
> I think Arnd fell asleep ;)

For some reason I did not get the original mail. I've added
the patch to my asm-generic queue and will send a pull request
together with other patches I got.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
