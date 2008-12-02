Date: Tue, 2 Dec 2008 07:12:01 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/8] badpage: simplify page_alloc flag check+clear
In-Reply-To: <Pine.LNX.4.64.0812020947440.5306@blonde.anvils>
Message-ID: <Pine.LNX.4.64.0812020710371.9474@quilx.com>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
 <Pine.LNX.4.64.0812010038220.11401@blonde.site> <Pine.LNX.4.64.0812010843230.15331@quilx.com>
 <Pine.LNX.4.64.0812012349330.18893@blonde.anvils> <Pine.LNX.4.64.0812012014150.30344@quilx.com>
 <Pine.LNX.4.64.0812020947440.5306@blonde.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russ Anderson <rja@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008, Hugh Dickins wrote:

> > But they are always clear on free. The checking is irrelevant.
>
> How about CHECK_PAGE_FLAGS_CLEAR_AT_FREE?

Strange name.

> The one I really disliked was "PAGE_FLAGS" for an obscure
> subset of page flags, and have got rid of that.

Good.

> > If (page->flags & (all the flags including dirty and SwapBacked))
> > 	zap-em.
>
> That's exactly what I did, isn't it?

Yes but you added another instance of this. Can you consolidate all the
check and clears into one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
