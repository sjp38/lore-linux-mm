Date: Wed, 18 Oct 2000 15:17:23 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <001b01c0393f$bc79ddc0$c958fc3e@brain>
Subject: Re: Page allocation (get_free_pages)
Message-Id: <20001018201641Z131175-246+60@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from "p.hamshere" <p.hamshere@ntlworld.com> on Wed, 18 Oct
2000 21:12:26 +0100


> I'm wondering why get_free_pages allocates contiguous pages for non-DMA transfers and why the kernel identity (ish) maps the whole (up to 1GB) of physical memory to its address space...

I can't answer the question as to why, although I suspect because it's a lot
easier,

I can say, however, that if gfp were to not return contiguous pages, it would
break my driver.



-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
