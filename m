Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55BB56B02F3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 13:44:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 67so5352640itx.11
        for <linux-mm@kvack.org>; Wed, 10 May 2017 10:44:57 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id l197si4276775itl.119.2017.05.10.10.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 10:44:56 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id 12so826855iol.1
        for <linux-mm@kvack.org>; Wed, 10 May 2017 10:44:56 -0700 (PDT)
From: Daniel Micay <danielmicay@gmail.com>
Subject: [PATCH] mark protection_map as __ro_after_init
Date: Wed, 10 May 2017 13:44:41 -0400
Message-Id: <20170510174441.26163-1-danielmicay@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com, Daniel Micay <danielmicay@gmail.com>

The protection map is only modified by per-arch init code so it can be
protected from writes after the init code runs.

This change was extracted from PaX where it's part of KERNEXEC.

Signed-off-by: Daniel Micay <danielmicay@gmail.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f82741e199c0..3bd5ecd20d4d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -94,7 +94,7 @@ static void unmap_region(struct mm_struct *mm,
  *								w: (no) no
  *								x: (yes) yes
  */
-pgprot_t protection_map[16] = {
+pgprot_t protection_map[16] __ro_after_init = {
 	__P000, __P001, __P010, __P011, __P100, __P101, __P110, __P111,
 	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
 };
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
