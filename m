Date: Thu, 22 May 2008 09:21:43 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default dma pad mask
Message-ID: <20080522012143.GA27975@gondor.apana.org.au>
References: <20080521214624Y.fujita.tomonori@lab.ntt.co.jp> <20080521131811.GA20212@gondor.apana.org.au> <20080522100712S.tomof@acm.org> <20080521.181945.27326326.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080521.181945.27326326.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 21, 2008 at 06:19:45PM -0700, David Miller wrote:
>
> > Ok, so it's all about crypto hardware requirement. In other words, if
> > we accept for potential performance drop of crypto hardware, crypto
> > can drop this alignment.
> 
> It sounds to me that Herbert is saying that the VIA crypto hardware
> will malfunction if not given an aligned address, rather than simply
> go more slowly.

Yes, in general hardware crypto that needs alignment requires it.
In VIA's case it will generate a GPF.

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
