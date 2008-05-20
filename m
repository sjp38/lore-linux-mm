Date: Wed, 21 May 2008 01:09:41 +0900
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080520153424.GA11687@gondor.apana.org.au>
References: <20080520093819.GA9147@gondor.apana.org.au>
	<20080520222531H.tomof@acm.org>
	<20080520153424.GA11687@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080521010942W.tomof@acm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: herbert@gondor.apana.org.au
Cc: fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008 23:34:24 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, May 20, 2008 at 10:25:25PM +0900, FUJITA Tomonori wrote:
> >
> > Does someone do DMA from/to __ctx?
> 
> Nobody.

Then, you don't need to use ARCH_KMALLOC_MINALIGN. 8 bytes align works
for you on all the architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
