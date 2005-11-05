Subject: Re: [PATCH] ppc64: 64K pages support
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20051105003819.GA11505@lst.de>
References: <1130915220.20136.14.camel@gaston>
	 <1130916198.20136.17.camel@gaston>  <20051105003819.GA11505@lst.de>
Content-Type: text/plain
Date: Sat, 05 Nov 2005 11:44:47 +1100
Message-Id: <1131151488.29195.46.camel@gaston>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@osdl.org>, linuxppc64-dev <linuxppc64-dev@ozlabs.org>, Linus Torvalds <torvalds@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2005-11-05 at 01:38 +0100, Christoph Hellwig wrote:
> So how does the 64k on 4k hardware emulation work?  When Hugh did
> bigger softpagesize for x86 based on 2.4.x he had to fix drivers all
> over to deal with that.

What was the problem with drivers ? On ppc64, it's all hidden in the
arch code. All the kernel sees is a 64k page size. I extended the PTE to
contain tracking informations for the 16 sub pages (HPTE bits & hash
slot index). Sub pages are faulted on demand and flushed all at once,
but it's all transparent to the generic code.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
