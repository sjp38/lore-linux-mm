Date: Wed, 21 May 2008 21:19:06 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default dma pad mask
Message-ID: <20080521131906.GB20212@gondor.apana.org.au>
References: <20080521210956C.tomof@acm.org> <20080521122218.GA19849@gondor.apana.org.au> <20080521214624Y.fujita.tomonori@lab.ntt.co.jp> <20080521215515G.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080521215515G.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 21, 2008 at 09:55:15PM +0900, FUJITA Tomonori wrote:
>
> > crypto hardware, it may be fine to use ALIGN_PTR for the hardware.
> 
> I still wonder it's acceptable or not.

Normally I would say yes.  But because the context poitner is
used on the most performance-critical path of the crypto API,
I'd rather not use it unless necessary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
