Received: from mars.matrox.com (mars.matrox.com [192.168.1.29])
	by itchy.matrox.com (Postfix) with ESMTP id B9D4F19E13
	for <linux-mm@kvack.org>; Wed, 14 Jul 2004 18:41:40 -0400 (EDT)
Received: (from root@localhost)
	by mars.matrox.com (8.11.6/8.11.6) id i6EMh9128140
	for <linux-mm@kvack.org>; Wed, 14 Jul 2004 18:43:09 -0400 (EDT)
Received: from dyn-152-170.matrox.com (dyn-152-170.matrox.com [192.168.152.170])
	by pluton.matrox.com (8.12.9/8.12.9) with ESMTP id i6EMh6hC027846
	for <linux-mm@kvack.org>; Wed, 14 Jul 2004 18:43:06 -0400 (EDT)
Subject: [Fwd: remap_page_range() vs nopage()]
From: Michel Hubert <mhubert@matrox.com>
Content-Type: text/plain
Message-Id: <1089844986.15840.144.camel@blackcomb>
Mime-Version: 1.0
Date: 14 Jul 2004 18:43:06 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, 

I previously posted this question to kernelnewbies.org but without 
getting any answer.  I hope it is not too basic for this mailing list...

It's written in Linux Device Driver 2nd edition that remap_page_range
(which maps an entire range at once) should be used for device IO
whereas nopage (which maps a single page at a time) should be used for
real physical memory.

However, I noticed that mmap_mem() in drivers/char/mem.c uses
exclusively remap_page_range.  How could this work when dealing with non
contiguous physical memory ?

Thank you, 

Michel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
