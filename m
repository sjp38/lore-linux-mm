Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080521012622.GA15850@gondor.apana.org.au>
References: <20080520153424.GA11687@gondor.apana.org.au>
	<20080521010942W.tomof@acm.org>
	<20080521012622.GA15850@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080521103651P.fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 21 May 2008 10:36:51 +0900
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: herbert@gondor.apana.org.au
Cc: fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 09:26:22 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, May 21, 2008 at 01:09:41AM +0900, FUJITA Tomonori wrote:
> >
> > Then, you don't need to use ARCH_KMALLOC_MINALIGN. 8 bytes align works
> > for you on all the architectures.
> 
> DMA isn't the only thing that requires alignment.  The CPU needs
> it too.  Also using a constant like 8 is broken because if we used
> a value larger than the alignment guaranteed by kmalloc then the
> context may end up unaligned.

ARCH_KMALLOC_MINALIGN represents DMA alignment since we guarantee
kmalloced buffers can be used for DMA.

Only non coherent architecutures defines ARCH_KMALLOC_MINALIGN to the
cache line size since an DMA'able object within a structure isn't
sharing a cache line with some other object (note that it not about
only alignment).

For your case, the alignment requirement for a pointer is appropriate
(it's about the CPU alignment requirement that you talk about. 8 bytes
alignment always works).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
