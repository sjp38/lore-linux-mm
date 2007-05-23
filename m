Date: Wed, 23 May 2007 13:32:24 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523183224.GD11115@waste.org>
References: <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com> <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com> <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <Pine.LNX.4.64.0705222326260.16694@schroedinger.engr.sgi.com> <20070523071200.GB9449@wotan.suse.de> <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 10:03:34AM -0700, Christoph Lameter wrote:
> On Wed, 23 May 2007, Nick Piggin wrote:
> 
> > On Tue, May 22, 2007 at 11:28:18PM -0700, Christoph Lameter wrote:
> > > On Wed, 23 May 2007, Nick Piggin wrote:
> > > 
> > > > If you want to do a memory consumption shootout with SLOB, you need
> > > > all the help you can get ;)
> > > 
> > > No way. And first you'd have to make SLOB functional. Among other 
> > > things it does not support slab reclaim.
> > 
> > What do you mean by slab reclaim? SLOB doesn't have slabs and it
> > never keeps around unused pages so I can't see how it would be able
> > to do anything more useful. SLOB is fully functional here, on my 4GB
> > desktop system, even.
> 
> SLOB does not f.e. handle the SLAB ZVCs. The VM will think there is no 
> slab use and never shrink the slabs.

You keep saying something like this but I'm never quite clear what you
mean. There are no slabs so reclaiming unused slabs is a non-issue.
Things like shrinking the dcache should work:

 __alloc_pages
  try_to_free_pages
   shrink_slab
    shrink_dcache_memory

I don't see any checks of ZVCs interfering with that path.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
