Date: Tue, 19 Jun 2007 15:33:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
In-Reply-To: <20070619210010.GN11166@waste.org>
Message-ID: <Pine.LNX.4.64.0706191532170.7633@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095914.622685354@sgi.com>
 <20070619210010.GN11166@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jun 2007, Matt Mackall wrote:

> I worry a bit about adding another branch checking __GFP_ZERO in such
> a hot path for SLAB/SLUB.

Its checking the gfpflags variable on the stack. In a recently touched 
cachline.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
