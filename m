Date: Wed, 23 May 2007 09:46:36 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523074636.GA10070@wotan.suse.de>
References: <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com> <20070523045938.GA29045@wotan.suse.de> <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com> <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com> <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com> <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070523061702.GA9449@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 08:17:02AM +0200, Nick Piggin wrote:
> On Tue, May 22, 2007 at 10:28:54PM -0700, Christoph Lameter wrote:
> > On Wed, 23 May 2007, Nick Piggin wrote:
> > 
> > > > This is intended for distro kernels so that you will not have to rebuild 
> > > > the kernel for slab debugging if slab corruption occurs.
> > > 
> > > OIC, neat. Anyway, the code size issue is still there, so I will
> > > test with the fix instead.
> > 
> > A code size issue? You mean SLUB is code wise larger than SLOB?
> 
> 
> That's what the numbers I just posted earlier indicate, yes.
> 
> If you want to do a memory consumption shootout with SLOB, you need
> all the help you can get ;)
> 
> OK, so with a 64-bit UP ppc kernel, compiled for size, and without full
> size data structures, booting with mem=16M init=/bin/bash.
> 
> 2.6.22-rc1-mm1 + your fix + my slob patches.
> 
> After booting and mounting /proc, SLOB has 1140K free, SLUB has 748K
> free.

Oh, and just out of interest, SLOB before my patches winds up with
1068K free, so it is good to know the patches were able to save a bit
on this setup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
