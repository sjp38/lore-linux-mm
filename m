Date: Thu, 25 Jan 2001 10:49:50 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3A705802.5C4DD2F2@augan.com>
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
	<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600 <20010125155345Z131181-221+38@kanga.kvack.org>
Subject: Re: ioremap_nocache problem?
Message-Id: <20010125164707Z131181-222+39@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <roman@augan.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

** Reply to message from Roman Zippel <roman@augan.com> on Thu, 25 Jan 2001
17:44:51 +0100


> set_bit(PG_reserved, &page->flags);
> 	ioremap();
> 	...
> 	iounmap();
> 	clear_bit(PG_reserved, &page->flags);

The problem with this is that between the ioremap and iounmap, the page is
reserved.  What happens if that page belongs to some disk buffer or user
process, and some other process tries to free it.  Won't that cause a problem?


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
