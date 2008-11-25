Date: Tue, 25 Nov 2008 12:58:27 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH] slab: __GFP_NOWARN not being propagated from
 mempool_alloc()
In-Reply-To: <Pine.LNX.4.64.0811250038030.11825@melkki.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0811251258010.18908@quilx.com>
References: <E1L4jMt-0006OW-5J@pomaz-ex.szeredi.hu>
 <Pine.LNX.4.64.0811250038030.11825@melkki.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-mm@kvack.org, david@fromorbit.com, peterz@infradead.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008, Pekka J Enberg wrote:

> Yes, it does but looking at mm/slab.c history I think we want something
> like the following instead. Christoph?

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
