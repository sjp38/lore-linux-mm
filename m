Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id E31726B006E
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 17:09:40 -0500 (EST)
Received: from web10g.yandex.ru (web10g.yandex.ru [95.108.252.110])
	by forward20.mail.yandex.net (Yandex) with ESMTP id B8CA510423DE
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 02:09:34 +0400 (MSK)
From: <vik@chelnydom.ru>
Subject: [PATCH] mm: include/linux/mm.h page_mapping() bug of swapcache case
MIME-Version: 1.0
Message-Id: <636271353190174@web10g.yandex.ru>
Date: Sun, 18 Nov 2012 02:09:34 +0400
Content-Transfer-Encoding: 7bit
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I run linux swap less and xwindows become not respond sometime. The bug is share swapper_space over all mappings of memory.
Also the dmesg show several lines which is hidden before. Test of 3.0.51 fail near the end of kernel compilation. I run 3.0.50
successly a hours.

*** linux-3.0.50.a/include/linux/mm.h	2012-10-31 20:51:59.000000000 +0400
--- linux-3.0.50.b/include/linux/mm.h	2012-11-17 19:44:56.864762720 +0400
***************
*** 787,793 ****
  	struct address_space *mapping = page->mapping;
  
  	VM_BUG_ON(PageSlab(page));
! 	if (unlikely(PageSwapCache(page)))
  		mapping = &swapper_space;
  	else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
  		mapping = NULL;
--- 787,793 ----
  	struct address_space *mapping = page->mapping;
  
  	VM_BUG_ON(PageSlab(page));
! 	if (likely(PageSwapCache(page)))
  		mapping = &swapper_space;
  	else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
  		mapping = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
