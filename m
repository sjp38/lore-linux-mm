Date: Thu, 20 Jul 2000 14:47:44 -0500
From: Timur Tabi <ttabi@interactivesi.com>
References: <20000719181648Z131171-4588+3@kanga.kvack.org> <20000720154702Z131167-4587+7@kanga.kvack.org>
In-Reply-To: <397725F8.34744F7A@colorfullife.com>
Subject: Re: Marking a physical page as uncacheable
Message-Id: <20000720200754Z131167-4584+7@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Manfred Spraul <manfred@colorfullife.com> on Thu, 20
Jul 2000 18:16:56 +0200


> You could use ClearPageReserved() + ioremap(), but ioremap() is limited
> to the first 4 GB.

Is there an ioUNremap()?  I need to perform tests on the memory region with the
cache disabled.  If the tests don't reveal what I'm looking for, then I need to
unallocate the block.  



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
