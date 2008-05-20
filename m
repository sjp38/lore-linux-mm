Date: Tue, 20 May 2008 18:58:17 +0900
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080520025231.b88bc71d.akpm@linux-foundation.org>
References: <20080520023129.2f921f24.akpm@linux-foundation.org>
	<20080520093819.GA9147@gondor.apana.org.au>
	<20080520025231.b88bc71d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080520185827U.tomof@acm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: herbert@gondor.apana.org.au, fujita.tomonori@lab.ntt.co.jp, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008 02:52:31 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 20 May 2008 17:38:20 +0800 Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Tue, May 20, 2008 at 02:31:29AM -0700, Andrew Morton wrote:
> > >
> > > So here you're using it for "dma aligment" whereas crypto is using it
> > > (or ARCH_SLAB_MINALIGN!) for "cpu 64-bit alignment".
> > 
> > No the 64-bit alignment is just an example.  The purpose of
> > CRYPTO_MINALIGN is pretty much the same as ARCH_KMALLOC_MINALIGN,
> > i.e., the minimum alignment guaranteed by kmalloc.  The only
> > reason it exists is because ARCH_KMALLOC_MINALIGN isn't defined
> > on all platforms.
> 
> I'm struggling to understand what you're saying here.
> 
> The comment you have there over the CRYPTO_MINALIGN definition is quite
> specific.  Is it wrong?
> 
> Whether the mapping between CRYPTO_MINALIGN and ARCH_KMALLOC_MINALIGN
> is abusive is (I find) hard to say, because first one would need to be
> able to say what ARCH_KMALLOC_MINALIGN is for.  I expect it was for DMA
> purposes.

Yeah, ARCH_KMALLOC_MINALIGN is for DMA. Non coherent platforms define
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
