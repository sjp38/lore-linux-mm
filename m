Date: Tue, 5 Jun 2001 15:59:38 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3B581215@MailAndNews.com>
Subject: Re: temp. mem mappings
Message-ID: <bYPDZD.A.c3.-gUH7@dinero.interactivesi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

** Reply to message from cohutta <cohutta@MailAndNews.com> on Tue, 5 Jun 2001
16:42:52 -0400


> I don't really want to play with the page tables if i can help it.
> I didn't use ioremap() because it's real system memory, not IO bus
> memory.
> 
> How much normal memory is identity-mapped at boot on x86?
> Is it more than 8 MB?

Much more.  Somewhere between 2 and 4 GB is mapped.  Large memory support in
Linux has always confused me, so I can't remember exactly how much is mapped.

Keep in mind that if you want to access that memory as uncached or
write-combined, you'll need to use the method I described.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
