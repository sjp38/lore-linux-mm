Date: Wed, 21 May 2008 11:16:46 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default dma pad mask
Message-ID: <20080521031646.GA16565@gondor.apana.org.au>
References: <20080520153424.GA11687@gondor.apana.org.au> <20080521010942W.tomof@acm.org> <20080521012622.GA15850@gondor.apana.org.au> <20080521103651P.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080521103651P.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 21, 2008 at 10:36:51AM +0900, FUJITA Tomonori wrote:
>
> ARCH_KMALLOC_MINALIGN represents DMA alignment since we guarantee
> kmalloced buffers can be used for DMA.

That may be why it was created, but that is not its only application.
In particular, it forms part of the calculation of the minimum
alignment guaranteed by kmalloc which is why it's used in crpyto.

Of course, if some kind soul would move this calculation into a
header file then we wouldn't be having this discussion.

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
