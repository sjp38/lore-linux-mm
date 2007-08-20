Date: Mon, 20 Aug 2007 12:12:30 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <1187595513.6114.176.camel@twins>
Message-ID: <Pine.LNX.4.64.0708201211240.20591@sbz-30.cs.Helsinki.FI>
References: <20070806102922.907530000@chello.nl>  <20070806103658.603735000@chello.nl>
 <1187595513.6114.176.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Mon, 20 Aug 2007, Peter Zijlstra wrote:
> -static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> +static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *reserve)
>  {

[snip]

> +	*reserve = page->reserve;

Any reason why the callers that are actually interested in this don't do 
page->reserve on their own?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
