Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52C446B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:49:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w37so8511448wrc.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:49:18 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id f141si4617339wme.164.2017.03.16.06.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 06:49:16 -0700 (PDT)
Message-ID: <1489672155.4458.7.camel@gmx.de>
Subject: [patch] KASAN: Do not sanitize kexec purgatory
From: Mike Galbraith <efault@gmx.de>
Date: Thu, 16 Mar 2017 14:49:15 +0100
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>


[   24.121074] kexec: Undefined symbol: __asan_load8_noabort
[   24.121999] kexec-bzImage64: Loading purgatory failed

Signed-off-by: Mike Galbraith <efault@gmx.de>
Cc: kasan-dev@googlegroups.com
---
 arch/x86/purgatory/Makefile |    1 +
 1 file changed, 1 insertion(+)

--- a/arch/x86/purgatory/Makefile
+++ b/arch/x86/purgatory/Makefile
@@ -8,6 +8,7 @@ PURGATORY_OBJS = $(addprefix $(obj)/,$(p
 LDFLAGS_purgatory.ro := -e purgatory_start -r --no-undefined -nostdlib -z nodefaultlib
 targets += purgatory.ro
 
+KASAN_SANITIZE	:= n
 KCOV_INSTRUMENT := n
 
 # Default KBUILD_CFLAGS can have -pg option set when FTRACE is enabled. That

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
