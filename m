Date: Wed, 21 May 2008 19:25:54 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default dma pad mask
Message-ID: <20080521112554.GA19558@gondor.apana.org.au>
References: <20080521084700.GA18644@gondor.apana.org.au> <20080521183429O.tomof@acm.org> <20080521100529.GA19077@gondor.apana.org.au> <20080521200104C.tomof@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080521200104C.tomof@acm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 21, 2008 at 08:01:12PM +0900, FUJITA Tomonori wrote:
>
> Why do algorithms require alignments bigger than ARCH_KMALLOC_MINALIGN?

Because the hardware may require it.  For example, the VIA Padlock
will fault unless the buffers are 16-byte aligned (it being an
x86-32 platform).

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
