Date: Thu, 20 Jul 2000 11:16:45 -0500
From: Timur Tabi <ttabi@interactivesi.com>
References: <20000719181648Z131171-4588+3@kanga.kvack.org> <20000720154702Z131167-4587+7@kanga.kvack.org>
In-Reply-To: <397725F8.34744F7A@colorfullife.com>
Subject: Re: Marking a physical page as uncacheable
Message-Id: <20000720163653Z131167-4587+8@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Manfred Spraul <manfred@colorfullife.com> on Thu, 20
Jul 2000 18:16:56 +0200


> You could use ClearPageReserved() + ioremap(), but ioremap() is limited
> to the first 4 GB.

The 4GB limit is okay for now.

What does ClearPageReserved do?  Does it make the kernel think that the page is
part of high memory?  



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
