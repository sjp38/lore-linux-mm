Received: from ms3.netsolmail.com (IDENT:mirapoint@[216.168.230.176])
	by omr2.netsolmail.com (8.12.10/8.12.10) with ESMTP id iB6JA4G6009205
	for <linux-mm@kvack.org>; Mon, 6 Dec 2004 14:10:04 -0500 (EST)
From: <evt@texelsoft.com>
Message-Id: <200412061910.CGY65252@ms3.netsolmail.com>
Date: Mon, 6 Dec 2004 14:10:02 -0500
Subject: Can remap_area_pages be made non-static
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

All,

What I'm trying to do is, in a situation where I have two
identical pci video cards where the framebuffer memory maps
the cards memory but only one is in use at a time, when a card
fails or is hot-removed, I'd like to unmap the memory from the
card that failed and remap the memory of the spare card to the
same virtual address. It seems to me that remap_area_pages()
does exactly what I desire but it's static.

Can this fn be made non-static or is there a better way to do
this? Please cc evt@texelsoft.com since my request to
subscribe to the list has not completed yet.

Thanks.

- Eric van Tassell
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
