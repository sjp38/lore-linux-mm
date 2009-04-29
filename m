Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C8A246B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 08:39:11 -0400 (EDT)
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20090429074511.GD3398@wotan.suse.de>
References: <20090414071152.GC23528@wotan.suse.de>
	 <20090415082507.GA23674@wotan.suse.de>
	 <20090415183847.d4fa1efb.akpm@linux-foundation.org>
	 <20090428185739.GE6377@localdomain> <20090429071233.GC3398@wotan.suse.de>
	 <20090429002418.fd9072a6.akpm@linux-foundation.org>
	 <20090429074511.GD3398@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 29 Apr 2009 08:39:22 -0400
Message-Id: <1241008762.6336.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ravikiran G Thirumalai <kiran@scalex86.org>, Sage Weil <sage@newdream.net>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-29 at 09:45 +0200, Nick Piggin wrote:
> On Wed, Apr 29, 2009 at 12:24:18AM -0700, Andrew Morton wrote:
> > On Wed, 29 Apr 2009 09:12:33 +0200 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > I haven't got any prepared, but they should be a pretty trivial
> > > backport, provided we also backport c2ec175c39f62949438354f603f4aa170846aabb
> > > (which is probably a good idea anyway).
> > > 
> > > However I will probably wait for a bit, given that the patch isn't upstream
> > > yet.
> > 
> > err, I'd marked it as for-2.6.31.  It looks like that was wrong?
> 
> At the time I agreed because I didn't know the severity of the NFS
> bugs. So it is up to you and Trond / nfs guys I guess.
> 

The bug affects any serious use of shared mmap writes, so it's pretty
urgent to get it merged together with the NFS 3 liner. As I said in an
earlier email, I'm able to reproduce it at will within 1 minute or so of
using iozone with the right options.

I also concur with the opinion that we should backport it to the stable
kernels as soon as possible.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
