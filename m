Message-ID: <3D5C139D.3E60701C@zip.com.au>
Date: Thu, 15 Aug 2002 13:48:29 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: kernel BUG at page_alloc.c:185! with 2.5.31 + akpm stuff
References: <1029432714.2051.232.camel@spc9.esa.lanl.gov>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> With this patch applied to 2.5.31,
> 
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/stuff-sent-to-linus/everything.gz
> 
> I got these BUGs,
> 
> kernel BUG at page_alloc.c:185!

This one's a worry.  A PageLRU(page) came off the buddy list.
This would tend to indicate that I goofed.

>  kernel BUG at page_alloc.c:98!

That's the BUG_ON(page->pte.chain).  Numerous people have been
getting that.  I had it a single time, about three kernels ago.
It's proving elusive.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
