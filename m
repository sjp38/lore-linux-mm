Date: Thu, 17 May 2007 22:22:17 -0700 (PDT)
Message-Id: <20070517.222217.112287075.davem@davemloft.net>
Subject: Re: [rfc] increase struct page size?!
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070518051238.GA7696@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de>
	<20070517.214740.51856086.davem@davemloft.net>
	<20070518051238.GA7696@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Fri, 18 May 2007 07:12:38 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> The page->virtual thing is just a bonus (although have you seen what
> sort of hoops SPARSEMEM has to go through to find page_address?! It
> will definitely be a win on those architectures).

If you set the bit ranges in asm/sparsemem.h properly, as I
have currently on sparc64, it isn't bad at all.  It's a
single extra dereference from a table that sits in the main
kernel image and thus is in a locked TLB entry.

SPARSEMEM_EXTREME is pretty much unnecessary and with the
virtual mem-map stuff the sparsemem overhead goes away entirely
and we're back to "page - mem_map" type simple calculations
obviating any dereferencing advantage from page->virtual.

> 0.2% of memory, or 2MB per GB. But considering we already use 14MB per
> GB for the page structures, it isn't like I'm introducing an order of
> magnitude problem.

All these little things add up, let's not suck like some other
OSs by having that kind of mentality.

Show me instead a change that makes page struct 8 bytes smaller
:-))))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
