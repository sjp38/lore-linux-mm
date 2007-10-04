Date: Thu, 4 Oct 2007 10:40:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [13/18] x86_64: Allow fallback for the stack
In-Reply-To: <200710041425.43343.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0710041039000.10854@schroedinger.engr.sgi.com>
References: <20071004035935.042951211@sgi.com> <200710041356.51750.ak@suse.de>
 <1191499692.22357.4.camel@twins> <200710041425.43343.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 4 Oct 2007, Andi Kleen wrote:

> > The order-1 allocation failures where GFP_ATOMIC, because SLUB uses !0
> > order for everything.
> 
> slub is wrong then. Can it be fixed?

SLUB in mm kernels was using higher order allocations for some slabs 
for the last 6 months or so. Not true for upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
