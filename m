Subject: Re: [RFC PATCH] slab: __GFP_NOWARN not being propagated from
	mempool_alloc()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <Pine.LNX.4.64.0811251258010.18908@quilx.com>
References: <E1L4jMt-0006OW-5J@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0811250038030.11825@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0811251258010.18908@quilx.com>
Content-Type: text/plain; charset=UTF-8
Date: Wed, 26 Nov 2008 10:10:21 +0200
Message-Id: <1227687021.31128.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-mm@kvack.org, david@fromorbit.com, peterz@infradead.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008, Pekka J Enberg wrote:
> > Yes, it does but looking at mm/slab.c history I think we want something
> > like the following instead. Christoph?

i>>?On Tue, 2008-11-25 at 12:58 -0600, Christoph Lameter wrote:
> Right.

OK, even though no tester showed up, I went ahead and merged my version
of the patch as it's a pretty obvious one-liner fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
