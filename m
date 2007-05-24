Date: Wed, 23 May 2007 19:55:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524024747.GD13694@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705231949590.23981@schroedinger.engr.sgi.com>
References: <20070523183224.GD11115@waste.org>
 <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com>
 <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com>
 <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com>
 <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com>
 <20070524020530.GA13694@wotan.suse.de> <Pine.LNX.4.64.0705231943550.23957@schroedinger.engr.sgi.com>
 <20070524024747.GD13694@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Nick Piggin wrote:

> Sure some things may be suboptimal, but the VM cannot just fall over
> and become non-functional if there is no reclaimable slab, surely?

The check in __vm_enough_memory in particular is worrying there.
Overcommit may not work right. If large caches are created via SLOB then
we may OOM.

Of course one can dismiss this by saying that the conditions under which 
this is true are rare etc etc.

Similarly the breakage of software suspend also did not matter..

Then swap prefetch (also using slab ZVCs) probably also does not matter. 

Guess embedded systems just have to be careful what kernel features they 
use and over time they can use less....





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
