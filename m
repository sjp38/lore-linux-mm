Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id F0C476B006E
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 18:50:33 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id ge10so46424178lab.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:33 -0800 (PST)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id gh10si18068684lbc.38.2015.02.02.15.50.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 15:50:32 -0800 (PST)
Received: by mail-la0-f54.google.com with SMTP id hv19so46193675lab.13
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 15:50:31 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 0/5] mm: Some .text savings
Date: Tue,  3 Feb 2015 00:50:11 +0100
Message-Id: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Only compile-tested, but I think these should be ok. Net saving aroung
450 bytes of .text.

Rasmus Villemoes (5):
  mm/internal.h: Don't split printk call in two
  mm/page_alloc.c: Pull out init code from build_all_zonelists
  mm/mm_init.c: Mark mminit_verify_zonelist as __init
  mm/mm_init.c: Mark mminit_loglevel __meminitdata
  kernel/cpuset.c: Mark cpuset_init_current_mems_allowed as __init

 kernel/cpuset.c |  2 +-
 mm/internal.h   |  6 ++++--
 mm/mm_init.c    |  4 ++--
 mm/page_alloc.c | 17 ++++++++++++++---
 4 files changed, 21 insertions(+), 8 deletions(-)

-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
