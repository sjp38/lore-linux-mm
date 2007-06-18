Date: Mon, 18 Jun 2007 19:09:09 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [patch 04/26] Slab allocators: Support __GFP_ZERO in all allocators.
Message-ID: <20070618100909.GB19056@linux-sh.org>
References: <20070618095838.238615343@sgi.com> <20070618095914.332369986@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070618095914.332369986@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Jun 18, 2007 at 02:58:42AM -0700, clameter@sgi.com wrote:
> So add the necessary logic to all slab allocators to support __GFP_ZERO.
> 
Does this mean I should update my SLOB NUMA support patch? ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
