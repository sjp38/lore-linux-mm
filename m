Date: Thu, 25 Sep 2008 05:07:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Message-ID: <20080925030738.GD4401@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de> <1222185029.4873.157.camel@koto.keithp.com> <20080925003021.GC23494@wotan.suse.de> <1222305622.4343.166.camel@koto.keithp.com> <20080925023014.GB4401@wotan.suse.de> <1222310606.4343.174.camel@koto.keithp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222310606.4343.174.camel@koto.keithp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Packard <keithp@keithp.com>
Cc: eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 24, 2008 at 07:43:26PM -0700, Keith Packard wrote:
> On Thu, 2008-09-25 at 04:30 +0200, Nick Piggin wrote:
> 
> > OK. I will have to add some facilities to allow mmaps that go back through
> > to tmpfs and be swappable... Thanks for the data point.
> 
> It seems like once you've done that you might consider extracting the
> page allocator from shmem so that drm, tmpfs and sysv IPC would share
> the same underlying memory manager API.

That might be the cleanest logical way to do it actually. But for the moment
I'm happy not to pull tmpfs apart :) Even if it seems like the wrong way
around, at least it is insulated to within mm/
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
