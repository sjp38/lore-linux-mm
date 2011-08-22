Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C6D726B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 12:27:19 -0400 (EDT)
Received: by iyn15 with SMTP id 15so11611798iyn.34
        for <linux-mm@kvack.org>; Mon, 22 Aug 2011 09:27:18 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 0/4] debug-pagealloc improvements
Date: Tue, 23 Aug 2011 01:29:04 +0900
Message-Id: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>

This patch series includes three improvements for the debug-pagealloc
feature for no-architecture support (!ARCH_SUPPORTS_DEBUG_PAGEALLOC) and
one introduction of the new string library function (memchr_inv).

Akinobu Mita (4):
  debug-pagealloc: use plain __ratelimit() instead of
    printk_ratelimit()
  debug-pagealloc: add support for highmem pages
  string: introduce memchr_inv
  debug-pagealloc: use memchr_inv

 fs/logfs/logfs.h       |    1 -
 fs/logfs/super.c       |   22 --------------
 include/linux/string.h |    1 +
 lib/string.c           |   54 +++++++++++++++++++++++++++++++++++
 mm/debug-pagealloc.c   |   73 +++++++++++++++++++++++------------------------
 mm/slub.c              |   47 +-----------------------------
 6 files changed, 93 insertions(+), 105 deletions(-)

-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
