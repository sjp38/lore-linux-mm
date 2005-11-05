Received: by xproxy.gmail.com with SMTP id i32so14336wxd
        for <linux-mm@kvack.org>; Fri, 04 Nov 2005 22:37:24 -0800 (PST)
Message-ID: <21d7e9970511042237p618d6306qb63272a4fa2263ea@mail.gmail.com>
Date: Sat, 5 Nov 2005 17:37:24 +1100
From: Dave Airlie <airlied@gmail.com>
Subject: Re: [PATCH] ppc64: 64K pages support
In-Reply-To: <1131151488.29195.46.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1130915220.20136.14.camel@gaston>
	 <1130916198.20136.17.camel@gaston> <20051105003819.GA11505@lst.de>
	 <1131151488.29195.46.camel@gaston>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@osdl.org>, linuxppc64-dev <linuxppc64-dev@ozlabs.org>, Linus Torvalds <torvalds@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> What was the problem with drivers ? On ppc64, it's all hidden in the
> arch code. All the kernel sees is a 64k page size. I extended the PTE to
> contain tracking informations for the 16 sub pages (HPTE bits & hash
> slot index). Sub pages are faulted on demand and flushed all at once,
> but it's all transparent to the generic code.
>

We did that with the VAX port about 5 years ago :-), granted for
different reasons..

The VAX has 512 byte hw pages, we had to make a 4K pagesize for the
kernel by grouping 8 hw pages together and hiding it all in the arch
dir..

granted I don't know if it broke any drivers, we didn't have any...

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
