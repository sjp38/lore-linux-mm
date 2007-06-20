Date: Wed, 20 Jun 2007 09:14:43 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
In-Reply-To: <Pine.LNX.4.64.0706191532170.7633@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0706200911200.10032@sbz-30.cs.Helsinki.FI>
References: <20070618095838.238615343@sgi.com> <20070618095914.622685354@sgi.com>
 <20070619210010.GN11166@waste.org> <Pine.LNX.4.64.0706191532170.7633@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jun 2007, Matt Mackall wrote:
> > I worry a bit about adding another branch checking __GFP_ZERO in such
> > a hot path for SLAB/SLUB.

On Tue, 19 Jun 2007, Christoph Lameter wrote:
> Its checking the gfpflags variable on the stack. In a recently touched 
> cachline.

The variable could be in a register too but it's the _branch 
instruction_ that is bit worrisome especially for embedded devices (think 
slob). I haven't measured this, so consider this as pure speculation and 
hand-waving from my part.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
