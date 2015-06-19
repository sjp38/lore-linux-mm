Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5996B0095
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:58:58 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so57892698qkb.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 07:58:58 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTP id e30si11104816qkh.102.2015.06.19.07.58.53
        for <linux-mm@kvack.org>;
        Fri, 19 Jun 2015 07:58:54 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 3/3] memtest: remove unused header files
Date: Fri, 19 Jun 2015 15:58:34 +0100
Message-Id: <1434725914-14300-4-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

memtest does not require these headers to be included.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 mm/memtest.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/memtest.c b/mm/memtest.c
index ccaed3e..fe08f70 100644
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
