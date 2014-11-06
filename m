Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 07EA66B009E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 10:31:39 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so1463794pab.4
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:31:38 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id kd7si6291881pbc.0.2014.11.06.07.31.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 07:31:37 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so1343203pdb.9
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:31:37 -0800 (PST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH/v2] Documentation: vm: Add 1GB large page support information
Date: Fri,  7 Nov 2014 00:31:15 +0900
Message-Id: <1415287875-18820-1-git-send-email-standby24x7@gmail.com>
In-Reply-To: <545AADCC.5030102@intel.com>
References: <545AADCC.5030102@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, corbet@lwn.net, linux-mm@kvack.org, dave.hansen@intel.com, lcapitulino@redhat.com, andi@firstfloor.org
Cc: Masanari Iida <standby24x7@gmail.com>

This patch adds 1GB large page support information in
Documentation/vm/hugetlbpage.txt

Reference:
https://lkml.org/lkml/2014/10/31/366

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/vm/hugetlbpage.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index b64e0af..f2d3a10 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -1,8 +1,8 @@
 
 The intent of this file is to give a brief summary of hugetlbpage support in
 the Linux kernel.  This support is built on top of multiple page size support
-that is provided by most modern architectures.  For example, i386
-architecture supports 4K and 4M (2M in PAE mode) page sizes, ia64
+that is provided by most modern architectures.  For example, x86 CPUs normally
+support 4K and 2M (1G if architecturally supported) page sizes, ia64
 architecture supports multiple page sizes 4K, 8K, 64K, 256K, 1M, 4M, 16M,
 256M and ppc64 supports 4K and 16M.  A TLB is a cache of virtual-to-physical
 translations.  Typically this is a very scarce resource on processor.
-- 
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
