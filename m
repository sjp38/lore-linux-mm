Date: Thu, 25 Jan 2001 09:56:32 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <20010125151655.V11607@redhat.com>
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org>
	<20010123165117Z131182-221+34@kanga.kvack.org> ; from ttabi@interactivesi.com on Tue, Jan 23, 2001 at 10:53:51AM -0600
Subject: Re: ioremap_nocache problem?
Message-Id: <20010125155345Z131181-221+38@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

** Reply to message from "Stephen C. Tweedie" <sct@redhat.com> on Thu, 25 Jan
2001 15:16:55 +0000


> ioremap*() is only supposed to be used on IO regions or reserved
> pages.  If you haven't marked the pages as reserved, then iounmap will
> do the wrong thing, so it's up to you to reserve the pages.

Au contraire!

I mark the page as reserved when I ioremap() it.  However, if I leave it marked
reserved, then iounmap() will not unmap it.  If I mark it "unreserved" (i.e.
reset the reserved bit), then iounmap will unmap it, but it will decrement the
page counter to -1 and the whole system will crash soon thereafter.

I've been asking about this problem for months, but no one has bothered to help
me out.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
