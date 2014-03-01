Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 41E4C6B005C
	for <linux-mm@kvack.org>; Sat,  1 Mar 2014 11:03:11 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id x10so1989062pdj.20
        for <linux-mm@kvack.org>; Sat, 01 Mar 2014 08:03:10 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id xe9si5737860pab.141.2014.03.01.08.03.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 01 Mar 2014 08:03:09 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id y10so2003046pdj.11
        for <linux-mm@kvack.org>; Sat, 01 Mar 2014 08:03:08 -0800 (PST)
From: Gideon Israel Dsouza <gidisrael@gmail.com>
Subject: [PATCH 0/1] Use macros from compiler.h instead of gcc specific attributes
Date: Sat,  1 Mar 2014 21:32:27 +0530
Message-Id: <1393689748-32236-1-git-send-email-gidisrael@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, geert@linux-m68k.org, Gideon Israel Dsouza <gidisrael@gmail.com>

To increase compiler portability there is <linux/compiler.h> which
provides convenience macros for various gcc constructs.  Eg: __weak for
__attribute__((weak)).  

I've taken up the job of cleaning these attributes all over the kernel.
Currently my patches for cleanup of all files under /kernel and /block
are already done and in the linux-next tree.

In the following patch I've replaced all aforementioned instances under
the /mm directory in the kernel source.

Gideon Israel Dsouza (1):
  mm: use macros from compiler.h instead of __attribute__((...))

 mm/hugetlb.c | 3 ++-
 mm/nommu.c   | 3 ++-
 mm/sparse.c  | 6 ++++--
 mm/util.c    | 5 +++--
 mm/vmalloc.c | 4 +++-
 5 files changed, 14 insertions(+), 7 deletions(-)

-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
