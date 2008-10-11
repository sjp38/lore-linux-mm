Message-ID: <48F06FA1.8060906@inria.fr>
Date: Sat, 11 Oct 2008 11:19:29 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use a radix-tree to make do_move_pages() complexity
 linear
References: <48EDF9DA.7000508@inria.fr> <48EFBBE9.5000703@linux-foundation.org> <48F069B8.6050709@inria.fr> <200810111958.12848.nickpiggin@yahoo.com.au>
In-Reply-To: <200810111958.12848.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nathalie.furmento@labri.fr
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> If you are worried about vmalloc overhead, I'd suggest testing with -mm.
> I've rewritten the vmap code so it is now slightly scalable and sane to
> use.
>   

I am actually only worried about move_pages() performance for large
buffers :) The vmalloc overhead is probably negligible against the
quadratic duration of move_pages() for dozens of MB.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
