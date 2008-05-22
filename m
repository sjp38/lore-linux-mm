Date: Thu, 22 May 2008 09:56:41 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default dma pad mask
Message-ID: <20080522015641.GA28199@gondor.apana.org.au>
References: <20080521131811.GA20212@gondor.apana.org.au> <20080522100712S.tomof@acm.org> <20080521.181945.27326326.davem@davemloft.net> <20080522103221C.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080522103221C.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: davem@davemloft.net, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 22, 2008 at 10:32:21AM +0900, FUJITA Tomonori wrote:
>
> What I asking is:
> 
> On most architectures, the minimum alignment guaranteed by kmalloc is
> too small (8 bytes). This ideal story doesn't happen to most of us.

Right, so the real issue is that what we have here is a lower
bound of the kmalloc alignment.  In reality, the kmalloc return
values are cache-line aligned when debugging is off.  So if you
can think of a way of getting a better bound at compile time,
I'm all ears.

Otherwise this discussion seems to be completely pointless.

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
