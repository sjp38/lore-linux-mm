Date: Tue, 23 Jan 2001 10:53:51 -0600
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <3A6D5D28.C132D416@sangate.com>
Subject: Re: ioremap_nocache problem?
Message-Id: <20010123165117Z131182-221+34@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

** Reply to message from Mark Mokryn <mark@sangate.com> on Tue, 23 Jan 2001
12:30:00 +0200


> Does this mean ioremap_nocache() may not do the job?

Good luck trying to get an answer.  I've been asking questions on ioremap for
months, but no one's ever been able to tell me anything.

According to the comments, mem.c provides /dev/zero support, whatever that is.
It doesn't appear to be connected to ioremap in any way, so I understand your
question.

I can tell you that I have written a driver that depends on ioremap_nocache,
and it does work, so it appears that ioremap_nocache is doing something.

My problem is that it's very easy to map memory with ioremap_nocache, but if
you use iounmap() the un-map it, the entire system will crash.  No one has been
able to explain that one to me, either.


-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please direct the reply to the mailing list only.  Don't send another copy to me.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
