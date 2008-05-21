Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080521031646.GA16565@gondor.apana.org.au>
References: <20080521012622.GA15850@gondor.apana.org.au>
	<20080521103651P.fujita.tomonori@lab.ntt.co.jp>
	<20080521031646.GA16565@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080521155414D.fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 21 May 2008 15:54:14 +0900
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: herbert@gondor.apana.org.au
Cc: fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 11:16:46 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, May 21, 2008 at 10:36:51AM +0900, FUJITA Tomonori wrote:
> >
> > ARCH_KMALLOC_MINALIGN represents DMA alignment since we guarantee
> > kmalloced buffers can be used for DMA.
> 
> That may be why it was created, but that is not its only application.

Currently, it's only applicaiton.


> In particular, it forms part of the calculation of the minimum
> alignment guaranteed by kmalloc which is why it's used in crpyto.
> 
> Of course, if some kind soul would move this calculation into a
> header file then we wouldn't be having this discussion.

As explained, with the current way we define ARCH_KMALLOC_MINALIGN,
crypto doesn't need to use it. But to make it clear, we had better
clean up these defines, such as renaming it an appropriate name like
ARCH_DMA_ALIGN.

I'll send patches shortly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
