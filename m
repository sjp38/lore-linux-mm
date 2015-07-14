Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id BCE7C9003C8
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 04:41:07 -0400 (EDT)
Received: by qgy5 with SMTP id 5so1137026qgy.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 01:41:07 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id h41si285292qge.80.2015.07.14.01.41.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Jul 2015 01:41:05 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH v2 3/3] memtest: remove unused header files
Date: Tue, 14 Jul 2015 09:40:49 +0100
Message-Id: <1436863249-1219-4-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com>
References: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, leon@leon.nu

memtest does not require these headers to be included.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 mm/memtest.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/memtest.c b/mm/memtest.c
index ca52d08..8bbb0c2 100644
--- a/mm/memtest.c
+++ b/mm/memtest.c
@@ -1,11 +1,6 @@
 #include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/string.h>
 #include <linux/types.h>
-#include <linux/mm.h>
-#include <linux/smp.h>
 #include <linux/init.h>
-#include <linux/pfn.h>
 #include <linux/memblock.h>
=20
 static u64 patterns[] __initdata =3D {
--=20
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
