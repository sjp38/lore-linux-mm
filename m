Message-ID: <391B2EB3.A79DFA63@timpanogas.com>
Date: Thu, 11 May 2000 16:05:39 -0600
From: "Jeff V. Merkey" <jmerkey@timpanogas.com>
MIME-Version: 1.0
Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

It should be expanded to support 64K pages.  Check
/usr/src/linux/include/asm-ia64/page.h.  IA64 supports page sizes up to
64K.  

:-)

Jeff

Linus Torvalds wrote:
> 
> On 11 May 2000, Juan J. Quintela wrote:
> > - we change one page_cache_release to put_page in truncate_inode_pages
> >   (people find lost when they see a get_page without the correspondent
> >   put_page, and put_page and page_cache_release are synonimops)
> 
> put_page() is _not_ synonymous with page_cache_release()!
> 
> Imagine a time in the not too distant future when the page cache
> granularity is 8kB or 16kB due to better IO performance (possibly
> controlled by a config option), and page_cache_release() will do an
> "order=1" or "order=2" page free..
> 
>                 Linus
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
