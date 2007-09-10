Date: Mon, 10 Sep 2007 18:40:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [0/35] intro
Message-Id: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, this patch set adds following functions

 - page_inode(page) ... returns inode from page, (page->mapping->host)
 - page_mapping_cache(page) ... returns addrees_space from page
 - page_mapping_anon(page) ... return anon_vma from page
 - page_is_pagecache(page) ... returns 1 if the page is page cache
 - pagecache_consistent(page, mapping) ... returns if page_mapping_cache(page)
   equals to mapping.

By adding aboves, this patch set removes all *direct* references to
page->mapping in usual codes. (compile tested with all mod config.)

I think this can improve VM/FS dependency and make things robust.
In addition,  page->mapping is not a just address_space, now.
(And we can hide page->mapping details from moduled FSs.)

patch set is structured as
[1] ... new interface definition
[2] ... changes in /mm
[3] ... changes in /kernel and /fs
[4...] ... changes in each FSs. (most of patches are very small.)

Any comments are welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
