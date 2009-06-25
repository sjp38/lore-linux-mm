Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0B55B6B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:38:01 -0400 (EDT)
Date: Fri, 26 Jun 2009 02:38:06 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] video: arch specific page protection support for deferred  io
Message-ID: <20090625173806.GB25320@linux-sh.org>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se> <20090624195647.9d0064c7.akpm@linux-foundation.org> <aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com> <20090625000359.7e201c58.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090625000359.7e201c58.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 25, 2009 at 12:03:59AM -0700, Andrew Morton wrote:
> On Thu, 25 Jun 2009 15:06:24 +0900 Magnus Damm <magnus.damm@gmail.com> wrote:
> > There are 3 levels of dependencies:
> > 1: pgprot_noncached() patches from Arnd
> > 2: mm: uncached vma support with writenotify
> > 3: video: arch specfic page protection support for deferred io
> > 
> > 2 depends on 1 to compile, but 3 (this one) is disconnected from 2 and
> > 1. So this patch can be merged independently.
> 
> OIC.  I didn't like the idea of improper runtime operation ;)
> 
> Still, it's messy.  If only because various trees might be running
> untested combinations of patches.  Can we get these all into the same
> tree?  Paul's?
> 
#1 is a bit tricky. cris has already merged the pgprot_noncached() patch,
which means only m32r and xtensa are outstanding, and unfortunately
neither one of those is very fast to pick up changes. OTOH, both of those
do include asm-generic/pgtable.h, so the build shouldn't break in -next
for those two if I merge #2 and #3, even if the behaviour won't be
correct for those platforms until they merge their pgprot_noncached()
patches (I think this is ok, since it's not changing any behaviour they
experience today anyways).

It would be nice to have an ack from someone for #2 before merging it,
but it's been out there long enough that people have had ample time to
raise objections.

So I'll make this the last call for acks or nacks on #2 and #3, if none
show up in the next couple of days, I'll fold them in to my tree and
they'll show up in -next starting next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
