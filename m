Date: Tue, 27 Jun 2000 13:57:58 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <8525690B.0067D1F0.00@D51MTA03.pok.ibm.com>
Subject: Re: Deleting an element from a free_list?
Message-Id: <20000627190814Z131176-21004+70@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from frankeh@us.ibm.com on Tue, 27 Jun 2000 14:55:15 -0400


> NO, it will NOT prevent the kernel of allocating these blocks. They have to
> be properly marked in the
> bitmaps of the buddy algorithm...

Damn, I knew I was forgetting something.

> You basically have to do what alloc_pages() does !!

*sigh* back to the source ...




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
