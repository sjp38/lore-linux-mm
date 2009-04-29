Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE4726B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 03:44:35 -0400 (EDT)
Date: Wed, 29 Apr 2009 09:45:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
Message-ID: <20090429074511.GD3398@wotan.suse.de>
References: <20090414071152.GC23528@wotan.suse.de> <20090415082507.GA23674@wotan.suse.de> <20090415183847.d4fa1efb.akpm@linux-foundation.org> <20090428185739.GE6377@localdomain> <20090429071233.GC3398@wotan.suse.de> <20090429002418.fd9072a6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090429002418.fd9072a6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 12:24:18AM -0700, Andrew Morton wrote:
> On Wed, 29 Apr 2009 09:12:33 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > I haven't got any prepared, but they should be a pretty trivial
> > backport, provided we also backport c2ec175c39f62949438354f603f4aa170846aabb
> > (which is probably a good idea anyway).
> > 
> > However I will probably wait for a bit, given that the patch isn't upstream
> > yet.
> 
> err, I'd marked it as for-2.6.31.  It looks like that was wrong?

At the time I agreed because I didn't know the severity of the NFS
bugs. So it is up to you and Trond / nfs guys I guess.


> all this:
> 
> #mm-close-page_mkwrite-races-try-3.patch: akpm issues!
> #mm-close-page_mkwrite-races-try-3.patch: check akpm hack
> mm-close-page_mkwrite-races-try-3.patch
> mm-close-page_mkwrite-races-try-3-update.patch
> mm-close-page_mkwrite-races-try-3-fix.patch
> mm-close-page_mkwrite-races-try-3-fix-fix.patch
> 
> is a bit of a worry.  But I guess we won't know until we merge it.

I have nothing against merging it now if you think it is needed.
It's only adding synchronisation, so I doubt it will cause a problem
that pushes the release out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
