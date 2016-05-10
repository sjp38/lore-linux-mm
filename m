Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC2A36B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 04:36:00 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so5111675lfq.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 01:36:00 -0700 (PDT)
Received: from relay06.alfahosting-server.de (relay06.alfahosting-server.de. [109.237.142.242])
        by mx.google.com with ESMTPS id gh2si1241945wjb.232.2016.05.10.01.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 01:35:59 -0700 (PDT)
Date: Tue, 10 May 2016 10:36:25 +0200
From: Richard Leitner <dev@g0hl1n.net>
Subject: [PATCH] mm/memblock.c: remove unnecessary always-true comparison
Message-ID: <20160510103625.3a7f8f32@g0hl1n.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Comparing an u64 variable to >=3D 0 returns always true and can therefore
be removed. This issue was detected using the -Wtype-limits gcc flag.

This patch fixes following type-limits warning:

mm/memblock.c: In function =E2=80=98__next_reserved_mem_region=E2=80=99:
mm/memblock.c:843:11: warning: comparison of unsigned expression >=3D 0 is
always true [-Wtype-limits]
  if (*idx >=3D 0 && *idx < type->cnt) {

Signed-off-by: Richard Leitner <dev@g0hl1n.net>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b570ddd..a1b8549 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -840,7 +840,7 @@ void __init_memblock __next_reserved_mem_region(u64
*idx, {
 	struct memblock_type *type =3D &memblock.reserved;
=20
-	if (*idx >=3D 0 && *idx < type->cnt) {
+	if (*idx < type->cnt) {
 		struct memblock_region *r =3D &type->regions[*idx];
 		phys_addr_t base =3D r->base;
 		phys_addr_t size =3D r->size;
--=20
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
