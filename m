Date: Wed, 23 May 2007 05:06:37 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523030637.GC9255@wotan.suse.de>
References: <20070522073910.GD17051@wotan.suse.de> <20070522145345.GN11115@waste.org> <Pine.LNX.4.64.0705221216300.30149@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705221216300.30149@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 22, 2007 at 12:18:58PM -0700, Christoph Lameter wrote:
> On Tue, 22 May 2007, Matt Mackall wrote:
> 
> > On Tue, May 22, 2007 at 09:39:10AM +0200, Nick Piggin wrote:
> > > Here are some patches I have been working on for SLOB, which makes
> > > it significantly faster, and also using less dynamic memory... at
> > > the cost of being slightly larger static footprint and more complex
> > > code.
> > > 
> > > Matt was happy for the first 2 to go into -mm (and hasn't seen patch 3 yet).
> > 
> > These all look good, thanks Nick!
> > 
> > Acked-by: Matt Mackall <mpm@selenic.com>
> 
> New SLUB inspired life for SLOB. I hope someone else tests this?

I'm sure there are people using SLOB, not sure if any of them test the
-mm tree, though. I am planning to get some size comparisons with other
allocators, which shouldn't take long (although I wouldn't know what a
representative tiny setup would look like).

 
> Are there any numbers / tests that give a continued reason for the 
> existence of SLOB? I.e. show some memory usage on a real system that is 
> actually lower than SLAB/SLUB? Or are there any confirmed platforms where 
> SLOB is needed?

The only real numbers I have off-hand are these

$ size mm/slob.o
   text    data     bss     dec     hex filename
   4160     792       8    4960    1360 mm/slob.o
$ size mm/slub.o
   text    data     bss     dec     hex filename
  11728    6468     176   18372    47c4 mm/slub.o

I'll see if I can get some basic dynamic memory numbers soon. The problem
is that slub oopses on boot on the powerpc platform I'm testing on...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
