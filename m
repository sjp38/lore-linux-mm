Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 41AB56B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 14:50:20 -0400 (EDT)
Date: Fri, 26 Jun 2009 03:50:47 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] video: arch specific page protection support for deferred io
Message-ID: <20090625185047.GA25916@linux-sh.org>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se> <20090624195647.9d0064c7.akpm@linux-foundation.org> <aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com> <20090625000359.7e201c58.akpm@linux-foundation.org> <20090625173806.GB25320@linux-sh.org> <20090625111233.f6f26050.akpm@linux-foundation.org> <45a44e480906251136l3a83188bm3f730534f89d00cb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45a44e480906251136l3a83188bm3f730534f89d00cb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, magnus.damm@gmail.com, linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 26, 2009 at 02:36:23AM +0800, Jaya Kumar wrote:
> On Fri, Jun 26, 2009 at 2:12 AM, Andrew Morton<akpm@linux-foundation.org> wrote:
> > On Fri, 26 Jun 2009 02:38:06 +0900
> > Paul Mundt <lethal@linux-sh.org> wrote:
> >
> >> On Thu, Jun 25, 2009 at 12:03:59AM -0700, Andrew Morton wrote:
> >> > On Thu, 25 Jun 2009 15:06:24 +0900 Magnus Damm <magnus.damm@gmail.com> wrote:
> >> > > There are 3 levels of dependencies:
> >> > > 1: pgprot_noncached() patches from Arnd
> >> > > 2: mm: uncached vma support with writenotify
> >> > > 3: video: arch specfic page protection support for deferred io
> >> > >
> >> > > 2 depends on 1 to compile, but 3 (this one) is disconnected from 2 and
> >> > > 1. So this patch can be merged independently.
> > <hunts around and finds #2>
> >
> > I don't really understand that one. ?Have we heard fro Jaya recently?
> >
> 
> He's been having some personal problems so he's been quiet. :-)
> 
> Magnus's defio changes, #3 look fine to me. I don't know much about #2
> but what I understood was that the previous mmap_region code was
> unintentionally turning caching back on when it did the writenotify
> test and I guess Magnus's goal with the patch is to make sure that
> address range is left uncached since sh_mobile uses DMA to transfer
> the framebuffer and he might have encountered coherency issues there?
> 
Correct. This could have been documented a bit better, but yes, the issue
is that when the writenotify test kicks in the vma silently loses its
uncachedness which leads to the aforementioned runtime behaviour issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
