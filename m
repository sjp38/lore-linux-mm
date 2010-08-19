Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0EDD76B02BC
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 12:42:29 -0400 (EDT)
Message-ID: <324015.78378.qm@web120304.mail.ne1.yahoo.com>
Date: Thu, 19 Aug 2010 09:42:41 -0700 (PDT)
From: Ten Up <tenuppunet@yahoo.com>
Subject: allocating very big contiguous memory
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I need to allocate 30M of contiguous memory in my driver.
I think kmalloc, get_free_pages and friends can allocate 4M at maximum.
Is there any other API that can allocate more than this?



      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
