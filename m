Date: Wed, 19 Jul 2000 12:57:10 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Marking a physical page as uncacheable
Message-Id: <20000719181648Z131171-4588+3@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

How can I make a kernel-allocated page of memory uncacheable?  The ioremap()
function lets me specify a bitflag, so I know it's possible without using MTRR's.



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
