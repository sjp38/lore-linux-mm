Subject: Re: [patch 3/5] slub: Support 4k kmallocs again to compensate for page allocator slowness
In-Reply-To: <20080214040313.855530089@sgi.com>
Message-ID: <ZDX5gaw0.1202972509.9474750.penberg@cs.helsinki.fi>
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Date: Thu, 14 Feb 2008 09:01:49 +0200 (EET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 2/14/2008, "Christoph Lameter" <clameter@sgi.com> wrote:
> Currently we hand off PAGE_SIZEd kmallocs to the page allocator in the
> mistaken belief that the page allocator can handle these allocations
> effectively. However, measurements indicate a mininum slowdown by the
> factor of 8 (and that is only SMP, NUMA is much worse) vs the slub
> fastpath which causes regressions in tbench.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
