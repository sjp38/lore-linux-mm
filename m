Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 399646B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 08:49:19 -0400 (EDT)
Message-ID: <224067.72201.qm@web120305.mail.ne1.yahoo.com>
Date: Wed, 18 Aug 2010 05:49:16 -0700 (PDT)
From: Ten Up <tenuppunet@yahoo.com>
Subject: maximum size that can be allocated by kmalloc and friends
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="0-47221208-1282135756=:72201"
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I need to allocate 30M of contiguous memory in my driver.
I think kmalloc, get_free_pages and friends can allocate 4M at maximum.
Is there any other API that can allocate more than this?

---
tenuppunet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
