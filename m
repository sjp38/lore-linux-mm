Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C87186B0036
	for <linux-mm@kvack.org>; Sat, 16 Aug 2014 17:14:54 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so5211743pdb.27
        for <linux-mm@kvack.org>; Sat, 16 Aug 2014 14:14:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c3si14543185pat.223.2014.08.16.14.14.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Aug 2014 14:14:53 -0700 (PDT)
Message-ID: <53EFC9CC.3060405@infradead.org>
Date: Sat, 16 Aug 2014 14:14:52 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] scripts/kernel-doc: recognize __meminit attribute
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix scripts/kernel-doc to recognize __meminit in a function prototype
and to stip it, as done with many other attributes.

Fixes this warning:
Warning(..//mm/page_alloc.c:2973): cannot understand function prototype: 'void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask) '

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 scripts/kernel-doc |    1 +
 1 file changed, 1 insertion(+)

Added to my patch queue.

Index: lnx-317-rc1/scripts/kernel-doc
===================================================================
--- lnx-317-rc1.orig/scripts/kernel-doc
+++ lnx-317-rc1/scripts/kernel-doc
@@ -2085,6 +2085,7 @@ sub dump_function($$) {
     $prototype =~ s/^noinline +//;
     $prototype =~ s/__init +//;
     $prototype =~ s/__init_or_module +//;
+    $prototype =~ s/__meminit +//;
     $prototype =~ s/__must_check +//;
     $prototype =~ s/__weak +//;
     my $define = $prototype =~ s/^#\s*define\s+//; #ak added

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
