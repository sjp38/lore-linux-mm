Date: Mon, 29 Oct 2007 18:25:15 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 02/10] SLUB: Noinline some functions to avoid them being folded into alloc/free
Message-ID: <20071029232515.GR17536@waste.org>
References: <20071028033156.022983073@sgi.com> <20071028033258.779134394@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071028033258.779134394@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 27, 2007 at 08:31:58PM -0700, Christoph Lameter wrote:
> Some function tend to get folded into __slab_free and __slab_alloc
> although they are rarely called. They cause register pressure that
> leads to bad code generation.

Nice - an example of uninlining to directly improve performance!

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
