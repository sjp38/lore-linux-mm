Date: Tue, 12 Aug 2008 06:27:51 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [RFC/PATCH] SLUB: dynamic per-cache MIN_PARTIAL
Message-ID: <20080812122751.GY8618@parisc-linux.org>
References: <Pine.LNX.4.64.0808050037400.26319@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808050037400.26319@sbz-30.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 05, 2008 at 12:39:36AM +0300, Pekka J Enberg wrote:
> This patch changes the static MIN_PARTIAL to a dynamic per-cache ->min_partial
> value that is calculated from object size. The bigger the object size, the more
> pages we keep on the partial list.
> 
> I tested SLAB, SLUB, and SLUB with this patch on Jens Axboe's 'netio' example
> script of the fio benchmarking tool. The script stresses the networking
> subsystem which should also give a fairly good beating of kmalloc() et al.

Hi Pekka,

We tested this patch and it was performance-neutral on TPC-C.  I was
hoping it would give a nice improvement ... so I'm disappointed.  But at
least there's no regression!

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
