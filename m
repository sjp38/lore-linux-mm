Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 417AE6B6707
	for <linux-mm@kvack.org>; Sun,  2 Dec 2018 22:51:08 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v2so9252741plg.6
        for <linux-mm@kvack.org>; Sun, 02 Dec 2018 19:51:08 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-oln040092008020.outbound.protection.outlook.com. [40.92.8.20])
        by mx.google.com with ESMTPS id o6si13058724plh.23.2018.12.02.19.51.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Dec 2018 19:51:06 -0800 (PST)
From: Yueyi Li <liyueyi@live.com>
Subject: [PATCH] memblock: Anonotate memblock_is_reserved() with
 __init_memblock.
Date: Mon, 3 Dec 2018 03:51:05 +0000
Message-ID: <BLUPR13MB0289EFC5F40ADCAC2146F687DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Found warring:

WARNING: EXPORT symbol "gsi_write_channel_scratch" [vmlinux] version genera=
tion failed, symbol will not be versioned.
WARNING: vmlinux.o(.text+0x1e0a0): Section mismatch in reference from the f=
unction valid_phys_addr_range() to the function .init.text:memblock_is_rese=
rved()
The function valid_phys_addr_range() references
the function __init memblock_is_reserved().
This is often because valid_phys_addr_range lacks a __init
annotation or the annotation of memblock_is_reserved is wrong.

Use __init_memblock instead of __init.

Signed-off-by: liyueyi <liyueyi@live.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 9a2d5ae..81ae63c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1727,7 +1727,7 @@ static int __init_memblock memblock_search(struct mem=
block_type *type, phys_addr
 	return -1;
 }
=20
-bool __init memblock_is_reserved(phys_addr_t addr)
+bool __init_memblock memblock_is_reserved(phys_addr_t addr)
 {
 	return memblock_search(&memblock.reserved, addr) !=3D -1;
 }
--=20
2.7.4
