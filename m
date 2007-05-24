Date: Thu, 24 May 2007 04:47:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524024747.GD13694@wotan.suse.de>
References: <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com> <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com> <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com> <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com> <20070524020530.GA13694@wotan.suse.de> <Pine.LNX.4.64.0705231943550.23957@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231943550.23957@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 07:45:37PM -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Nick Piggin wrote:
> 
> > SLOB doesn't keep track of what pages might be reclaimable, so yes
> > it reports zero to the VM. That doesn't make it non functional or
> > even prevent slab reclaim from working.
> 
> It does make the counters useless. The VM activities that depend on these
> will not work.

Sure some things may be suboptimal, but the VM cannot just fall over
and become non-functional if there is no reclaimable slab, surely?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
