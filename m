Date: Tue, 9 Jan 2001 11:35:09 -0600
From: Timur Tabi <ttabi@interactivesi.com>
Subject: ioremap doesn't increment page->count, but iounmap decrements it
Message-Id: <20010109173247Z131189-223+7@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I just discovered an oddity in 2.2.18pre15.  When ioremap() is used to map
reserved pages (of real RAM), it does not increment the "count" field for the
page it remaps (i.e. page->count).  However, when you call iounmap on that
memory, that function decrements page->count.  Since the count was originally
zero, it gets decremented to -1, and that's when things start to go bad.

I get the feeling that if I remap reserved memory, I'm not supposed to ever
unmap it.  But that means that my driver will have a memory leak.  Can someone
help me out?


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
