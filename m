Date: Mon, 25 Jun 2007 01:20:36 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] slob: poor man's NUMA support.
Message-ID: <20070625062036.GJ11115@waste.org>
References: <20070619090616.GA23697@linux-sh.org> <467F5E14.5030401@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <467F5E14.5030401@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 25, 2007 at 04:17:56PM +1000, Nick Piggin wrote:
> Paul Mundt wrote:
> >This adds preliminary NUMA support to SLOB, primarily aimed at systems
> >with small nodes (tested all the way down to a 128kB SRAM block), whether
> >asymmetric or otherwise.
> 
> Fine by me as well, FWIW. My points about per-cpu/node queues were not
> to say that I'm really opposed to getting this in first. In a way, you
> sell yourself short with the patch name: the implementation may be just
> a basic one, but simplicity is a key point of SLOB... Adding numa
> awareness to the slob APIs is obviously a key step and makes it much
> easier to experiment with enhancements to the implementation.
> 
> Unless it has been picked up already, I'd call it "initial NUMA support"
> ;) Thanks! Would be great to hear about your experiences using SLOB as
> well -- how much memory you're saving, how it performs, etc.

I haven't seen the usual echo from Andrew, so I think Paul should
resend it with three Acked-bys.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
