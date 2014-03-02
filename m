Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 98E926B0035
	for <linux-mm@kvack.org>; Sun,  2 Mar 2014 08:40:18 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so2640479pdj.17
        for <linux-mm@kvack.org>; Sun, 02 Mar 2014 05:40:18 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id on3si7595393pbb.35.2014.03.02.05.40.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 02 Mar 2014 05:40:17 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id kq14so2700301pab.37
        for <linux-mm@kvack.org>; Sun, 02 Mar 2014 05:40:16 -0800 (PST)
From: Gideon Israel Dsouza <gidisrael@gmail.com>
Subject: [PATCH 0/1] mm: Use macros from compiler.h instead of gcc specific attribute
Date: Sun,  2 Mar 2014 19:09:57 +0530
Message-Id: <1393767598-15954-1-git-send-email-gidisrael@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, geert@linux-m68k.org, Gideon Israel Dsouza <gidisrael@gmail.com>

I'm extremely sorry about the mistake in the earlier patch.

The following patch is a corrected one.

================== Original Cover Letter ==================
To increase compiler portability there is <linux/compiler.h> which
provides convenience macros for various gcc constructs.  Eg: __weak for
__attribute__((weak)).

I've taken up the job of cleaning these attributes all over the kernel.
Currently my patches for cleanup of all files under /kernel and /block
are already done and in the linux-next tree.

In the following patch I've replaced all aforementioned instances under
the /mm directory in the kernel source.
==============================================================

Gideon Israel Dsouza (1):
  mm: use macros from compiler.h instead of __attribute__((...))

 mm/hugetlb.c | 3 ++-
 mm/nommu.c   | 3 ++-
 mm/sparse.c  | 4 +++-
 mm/util.c    | 5 +++--
 mm/vmalloc.c | 4 +++-
 5 files changed, 13 insertions(+), 6 deletions(-)

-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
