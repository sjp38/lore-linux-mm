Date: Thu, 24 May 2007 05:17:00 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524031700.GB14349@wotan.suse.de>
References: <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com> <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com> <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com> <20070524020530.GA13694@wotan.suse.de> <Pine.LNX.4.64.0705231943550.23957@schroedinger.engr.sgi.com> <20070524024747.GD13694@wotan.suse.de> <Pine.LNX.4.64.0705231949590.23981@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231949590.23981@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 07:55:56PM -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Nick Piggin wrote:
> 
> > Sure some things may be suboptimal, but the VM cannot just fall over
> > and become non-functional if there is no reclaimable slab, surely?
> 
> The check in __vm_enough_memory in particular is worrying there.
> Overcommit may not work right. If large caches are created via SLOB then
> we may OOM.

On the other hand, if I enabled overcommit on an embedded system, then I
might prefer not to call any slab memory reclaimable because you don't
actually know if it is able to be reclaimed anyway.

 
> Of course one can dismiss this by saying that the conditions under which 
> this is true are rare etc etc.
> 
> Similarly the breakage of software suspend also did not matter..
> 
> Then swap prefetch (also using slab ZVCs) probably also does not matter. 
> 
> Guess embedded systems just have to be careful what kernel features they 
> use and over time they can use less....

Anyway, this is just going around in circles, because the embedded
people using SLOB actually use it for the feature that it very memory
efficient, which is something the other allocators do not have. But
you just keep dismissing that...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
