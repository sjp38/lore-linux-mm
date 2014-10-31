Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E244F280050
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:02:16 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so7974505pad.17
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 09:02:16 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ab8si9620934pbd.32.2014.10.31.09.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 09:02:15 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so8017628pad.29
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 09:02:15 -0700 (PDT)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] Documentation: vm: Add 1GB large page support information
Date: Sat,  1 Nov 2014 01:01:57 +0900
Message-Id: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: corbet@lwn.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lcapitulino@redhat.com
Cc: Masanari Iida <standby24x7@gmail.com>

This patch add 1GB large page support information on
x86_64 architecture in Documentation/vm/hugetlbpage.txt.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/vm/hugetlbpage.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index bdd4bb9..0a2bf4f 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -2,7 +2,8 @@
 The intent of this file is to give a brief summary of hugetlbpage support in
 the Linux kernel.  This support is built on top of multiple page size support
 that is provided by most modern architectures.  For example, i386
-architecture supports 4K and 4M (2M in PAE mode) page sizes, ia64
+architecture supports 4K and 4M (2M in PAE mode) page sizes, x86_64
+architecture supports 4K, 2M and 1G (SandyBridge or later) page sizes. ia64
 architecture supports multiple page sizes 4K, 8K, 64K, 256K, 1M, 4M, 16M,
 256M and ppc64 supports 4K and 16M.  A TLB is a cache of virtual-to-physical
 translations.  Typically this is a very scarce resource on processor.
-- 
2.1.2.555.gfbecd99

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
