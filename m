Date: Tue, 10 Jul 2007 17:40:46 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 09/10] Remove the SLOB allocator for 2.6.23
Message-ID: <20070710224046.GV11115@waste.org>
References: <20070708075119.GA16631@elte.hu> <20070708110224.9cd9df5b.akpm@linux-foundation.org> <4691A415.6040208@yahoo.com.au> <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com> <Pine.LNX.4.64.0707090907010.13970@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0707101049230.23040@sbz-30.cs.Helsinki.FI> <469342DC.8070007@yahoo.com.au> <84144f020707100231p5013e1aer767562c26fc52eeb@mail.gmail.com> <20070710120224.GP11115@waste.org> <Pine.LNX.4.64.0707101510410.5490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707101510410.5490@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com, corey.d.gough@intel.com, Denis Vlasenko <vda.linux@googlemail.com>, Erik Andersen <andersen@codepoet.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 10, 2007 at 03:12:38PM -0700, Christoph Lameter wrote:
> On Tue, 10 Jul 2007, Matt Mackall wrote:
> 
> > following as the best MemFree numbers after several boots each:
> > 
> > SLAB: 54796
> > SLOB: 55044
> > SLUB: 53944
> > SLUB: 54788 (debug turned off)
> 
> That was without "slub_debug" as a parameter or with !CONFIG_SLUB_DEBUG?

Without the parameter, as the other way doesn't compile in -mm1.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
