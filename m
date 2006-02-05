Subject: Re: [RFT/PATCH] slab: consolidate allocation paths
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1139128872.11782.5.camel@localhost>
References: <1139060024.8707.5.camel@localhost>
	 <Pine.LNX.4.62.0602040709210.31909@graphe.net>
	 <1139070369.21489.3.camel@localhost> <1139070779.21489.5.camel@localhost>
	 <20060204180026.b68e9476.pj@sgi.com>  <1139128872.11782.5.camel@localhost>
Date: Sun, 05 Feb 2006 11:18:29 +0200
Message-Id: <1139131109.11782.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: christoph@lameter.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

On Sun, 2006-02-05 at 10:41 +0200, Pekka Enberg wrote:
> Ah, sorry about that, I forgot to verify the NUMA case. The problem is
> that to kmalloc_node() is calling cache_alloc() now which is forced
> inline. I am wondering, would it be ok to make __cache_alloc()
> non-inline for NUMA? The relevant numbers are:

[snip]

Btw, we can also change kmalloc_node() to use kmem_cache_alloc_node()
again but for that, we have a minor correctness issue, namely, the
__builtin_return_address(0) won't work for kmalloc_node(). Hmm.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
