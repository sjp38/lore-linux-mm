Date: Sat, 5 Nov 2005 01:38:19 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] ppc64: 64K pages support
Message-ID: <20051105003819.GA11505@lst.de>
References: <1130915220.20136.14.camel@gaston> <1130916198.20136.17.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130916198.20136.17.camel@gaston>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@osdl.org>, linuxppc64-dev <linuxppc64-dev@ozlabs.org>, Linus Torvalds <torvalds@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

So how does the 64k on 4k hardware emulation work?  When Hugh did
bigger softpagesize for x86 based on 2.4.x he had to fix drivers all
over to deal with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
