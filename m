From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Date: Thu, 2 Oct 2008 10:15:55 -0700
References: <20080923091017.GB29718@wotan.suse.de> <1222737005.21655.61.camel@vonnegut.anholt.net>
In-Reply-To: <1222737005.21655.61.camel@vonnegut.anholt.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810021015.55880.jbarnes@virtuousgeek.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Anholt <eric@anholt.net>
Cc: Nick Piggin <npiggin@suse.de>, keith.packard@intel.com, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Monday, September 29, 2008 6:10 pm Eric Anholt wrote:
> On Tue, 2008-09-23 at 11:10 +0200, Nick Piggin wrote:
> > If my cursory reading is correct, then my allocator won't work so well as
> > a drop in replacement because one isn't allowed to know about the filp
> > behind the pageable object. It would also indicate some serious crack
> > smoking by anyone who thinks open(2), pread(2), mmap(2), etc is ugly in
> > comparison...
>
> I think the explanation for this got covered in other parts of the
> thread, but drm_gem.c comments at the top also cover it.
>
> > So please, nobody who worked on that code is allowed to use ugly as an
> > argument. Technical arguments are fine, so let's try to cover them.

I don't think anyone would argue that using normal system calls would be ugly, 
but there are several limitations with that approach, including the fact that 
some of our operations become slightly more difficult to do, along with the 
other limitations mentioned in drm_gem.c and in other threads.

At this point I think we should go ahead and include Eric's earlier patchset 
into drm-next, and continue to refine the internals along the lines of what 
you've posted here in the post-2.6.28 timeframe.  The ioctl based interfaces 
(there aren't too many) are something we can support going forward, so we 
should be able to rip up/clean up the implementation over time as the VM 
becomes more friendly to these sort of operations.

Any objections?

Dave, you can add my Acked-by (or S-o-b if Eric includes my GTT mapping stuff) 
to Eric's patchset; hope you can do that soon so we can get a libdrm with the 
new APIs released soon.

Thanks,
-- 
Jesse Barnes, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
