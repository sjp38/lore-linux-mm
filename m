Message-ID: <20030917171927.66889.qmail@web12304.mail.yahoo.com>
Date: Wed, 17 Sep 2003 10:19:27 -0700 (PDT)
From: Ravi Krishnamurthy <kravi26@yahoo.com>
Subject: Re: __vmalloc and alloc_page
In-Reply-To: <200309171326.11848.lmb@exatas.unisinos.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Leandro Motta Barros <lmb@exatas.unisinos.br>, linux-mm@kvack.org
Cc: sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

--- Leandro Motta Barros <lmb@exatas.unisinos.br> wrote:

> '__vmalloc()' allocates its memory by calling 
> 'alloc_page()' for every necessary page. Wouldn't
> it be better calling 'alloc_pages()' to allocate
> more pages at once whenever possible?

Higher order allocations are more likely to fail
because of fragmentation. Besides, vmalloc() is
intended to be used when the caller does not really
need physically contiguous pages. So calling
alloc_pages() within vmalloc seems pointless. 
If alloc_pages fails, you will have to fall back to
a lower order allocation anyway.



__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free, easy-to-use web site design software
http://sitebuilder.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
