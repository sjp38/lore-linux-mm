Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id BAF6C9003C8
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 04:41:05 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so1681707qkd.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 01:41:05 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id p20si307314qkp.14.2015.07.14.01.41.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Jul 2015 01:41:04 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH v2 1/3] memtest: use kstrtouint instead of simple_strtoul
Date: Tue, 14 Jul 2015 09:40:47 +0100
Message-Id: <1436863249-1219-2-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com>
References: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, leon@leon.nu

Since simple_strtoul is obsolete and memtest_pattern is type of int, use
kstrtouint instead.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 mm/memtest.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/memtest.c b/mm/memtest.c
index 0a1cc13..20e8361 100644
--- a/mm/memtest.c
+++ b/mm/memtest.c
@@ -89,16 +89,18 @@ static void __init do_one_pass(u64 pattern, phys_addr_t=
 start, phys_addr_t end)
 }
=20
 /* default is disabled */
-static int memtest_pattern __initdata;
+static unsigned int memtest_pattern __initdata;
=20
 static int __init parse_memtest(char *arg)
 {
+=09int ret =3D 0;
+
 =09if (arg)
-=09=09memtest_pattern =3D simple_strtoul(arg, NULL, 0);
+=09=09ret =3D kstrtouint(arg, 0, &memtest_pattern);
 =09else
 =09=09memtest_pattern =3D ARRAY_SIZE(patterns);
=20
-=09return 0;
+=09return ret;
 }
=20
 early_param("memtest", parse_memtest);
--=20
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
