Date: Thu, 08 Jun 2000 16:44:21 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Allocating a page of memory with a given physical address
Message-Id: <20000608220756Z131165-245+106@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I have an application that needs to allocate a page of RAM on a given physical
address.  IOW, say I have a physical address (e.g. 0x0CDB5000 on a 256MB
machine), and I know (via the mem_map array) that it's not being used by
anything.  What I need to do know is allocate that page of memory so that no one
else can allocate it (via a memory allocation function like get_free_page or
malloc).

Is this currently possible?  If not, is anyone working on adding it to a future
kernel?  And if not, is anyone willing to help me implement it or at least tell
me how I should proceed?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
