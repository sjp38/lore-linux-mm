Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C0B5F6B00BA
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 08:42:50 -0500 (EST)
Message-Id: <4B06AAE802000078000211CC@vpn.id2.novell.com>
Date: Fri, 20 Nov 2009 13:42:48 +0000
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] properly __init-annotate bootmem helper functions
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 mm/bootmem.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- linux-2.6.32-rc8/mm/bootmem.c	2009-11-20 14:11:50.000000000 =
+0100
+++ 2.6.32-rc8-bootmem-align-functions/mm/bootmem.c	2009-11-20 =
11:23:52.000000000 +0100
@@ -408,8 +408,8 @@ int __init reserve_bootmem(unsigned long
 	return mark_bootmem(start, end, 1, flags);
 }
=20
-static unsigned long align_idx(struct bootmem_data *bdata, unsigned long =
idx,
-			unsigned long step)
+static unsigned long __init align_idx(struct bootmem_data *bdata,
+				      unsigned long idx, unsigned long =
step)
 {
 	unsigned long base =3D bdata->node_min_pfn;
=20
@@ -421,8 +421,8 @@ static unsigned long align_idx(struct bo
 	return ALIGN(base + idx, step) - base;
 }
=20
-static unsigned long align_off(struct bootmem_data *bdata, unsigned long =
off,
-			unsigned long align)
+static unsigned long __init align_off(struct bootmem_data *bdata,
+				      unsigned long off, unsigned long =
align)
 {
 	unsigned long base =3D PFN_PHYS(bdata->node_min_pfn);
=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
