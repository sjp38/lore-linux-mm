Date: Sun, 1 Jun 2003 14:53:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.70-bk4+: oops by mc -v /proc/bus/pci/00/00.0
Message-ID: <20030601215349.GB20413@holomorphy.com>
References: <20030531165523.GA18067@steel.home> <20030531195414.10c957b7.akpm@digeo.com> <20030601143439.O626@nightmaster.csn.tu-chemnitz.de> <20030601125809.4e28453e.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030601125809.4e28453e.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 01, 2003 at 12:58:09PM -0700, Andrew Morton wrote:
> Well not really.  Yes, a slab-based ctor would be nice, but it requires that
> all objects be kfreed in a "constructed" state.  So a full audit/fixup of
> all users is needed.
> For now I was thinking more along the lines of
> struct vma_struct alloc_vma(gfp_flags)
> {
> 	vma = kmem_cache_alloc();
> 	memset(vma);
> 	return vma;
> }
> And then deleting tons of open-coded init stuff elsewhere...

I'll add vma ctor bits to my TODO list, behind numerous other things..


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
