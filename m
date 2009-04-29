Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 933686B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:27:26 -0400 (EDT)
Date: Wed, 29 Apr 2009 00:24:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
Message-Id: <20090429002418.fd9072a6.akpm@linux-foundation.org>
In-Reply-To: <20090429071233.GC3398@wotan.suse.de>
References: <20090414071152.GC23528@wotan.suse.de>
	<20090415082507.GA23674@wotan.suse.de>
	<20090415183847.d4fa1efb.akpm@linux-foundation.org>
	<20090428185739.GE6377@localdomain>
	<20090429071233.GC3398@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Apr 2009 09:12:33 +0200 Nick Piggin <npiggin@suse.de> wrote:

> On Tue, Apr 28, 2009 at 11:57:39AM -0700, Ravikiran G Thirumalai wrote:
> > On Wed, Apr 15, 2009 at 06:38:47PM -0700, Andrew Morton wrote:
> > >On Wed, 15 Apr 2009 10:25:07 +0200 Nick Piggin <npiggin@suse.de> wrote:
> > >
> > >> - Trond for NFS (http://bugzilla.kernel.org/show_bug.cgi?id=12913).
> > >
> > >I wonder which kernel version(s) we should put this in.
> > >
> > >Going BUG isn't nice, but that report is against 2.6.27.  Is the BUG
> > >super-rare, or did we avoid it via other means, or what?
> > >
> > 
> > Jumping in late in  after being bit by this bug many times
> > over with  2.6.27.  The bug (http://bugzilla.kernel.org/show_bug.cgi?id=12913)
> > is not rare with the right workload at all.
> 
> Good data point, thanks.
> 
> 
> > I can easily make it happen on smp machines, when multiple
> > processes are writing to the same NFS mounted file system.  AFAICT this
> > needs to be back ported to 27 stable and 29 stable as well.
> > 
> > Nick, are there 27 based patches already available someplace?
> > Obviously, I have verified these patches + Trond's patch --
> > http://lkml.org/lkml/2009/4/25/64 fixes the issue with 2.6.30-rc3
> 
> I haven't got any prepared, but they should be a pretty trivial
> backport, provided we also backport c2ec175c39f62949438354f603f4aa170846aabb
> (which is probably a good idea anyway).
> 
> However I will probably wait for a bit, given that the patch isn't upstream
> yet.

err, I'd marked it as for-2.6.31.  It looks like that was wrong?

all this:

#mm-close-page_mkwrite-races-try-3.patch: akpm issues!
#mm-close-page_mkwrite-races-try-3.patch: check akpm hack
mm-close-page_mkwrite-races-try-3.patch
mm-close-page_mkwrite-races-try-3-update.patch
mm-close-page_mkwrite-races-try-3-fix.patch
mm-close-page_mkwrite-races-try-3-fix-fix.patch

is a bit of a worry.  But I guess we won't know until we merge it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
