Received: from lexa.home.net (IDENT:root@mail.datafoundation.com [10.0.0.4])
	by datafoundation.com (8.9.3/8.9.3) with SMTP id QAA20511
	for <linux-mm@kvack.org>; Sun, 6 May 2001 16:36:50 -0400
Message-Id: <200105062036.QAA20511@datafoundation.com>
Date: Mon, 7 May 2001 00:37:53 +0400
From: Alexey Zhuravlev <alexey@datafoundation.com>
Subject: accounting bh->b_count in page->count
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello!

why do not change bh->b_page->count on getblk/brelse?
this could prevent situation when a page that can't be
freed by try_to_free_buffers from buffercache lives on
inactive_dirty list and VM try to free it every time...

--
poka, lexa
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
