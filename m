Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 600F76B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 21:29:19 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id o61so6311891pld.5
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 18:29:19 -0800 (PST)
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-oln040092253029.outbound.protection.outlook.com. [40.92.253.29])
        by mx.google.com with ESMTPS id r19si6021448pfi.100.2018.02.19.18.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 18:29:18 -0800 (PST)
From: ? ? <mordorw@hotmail.com>
Subject: [PATCH] slab: fix /proc/slabinfo alignment
Date: Tue, 20 Feb 2018 02:29:13 +0000
Message-ID: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "cl@linux.com" <cl@linux.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, ? ? <mordorw@hotmail.com>

Signed-off-by: mordor <mordorw@hotmail.com>
/proc/slabinfo is not aligned, it is difficult to read, so correct it

---
 mm/slab_common.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 10f127b..7111549 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1232,7 +1232,6 @@ void cache_random_seq_destroy(struct kmem_cache *cach=
ep)
 #else
 #define SLABINFO_RIGHTS S_IRUSR
 #endif
-
 static void print_slabinfo_header(struct seq_file *m)
 {
 	/*
@@ -1244,7 +1243,7 @@ static void print_slabinfo_header(struct seq_file *m)
 #else
 	seq_puts(m, "slabinfo - version: 2.1\n");
 #endif
-	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objper=
slab> <pagesperslab>");
+	seq_puts(m, "# name                         <active_objs> <num_objs> <obj=
size> <objperslab> <pagesperslab>");
 	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
 	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
 #ifdef CONFIG_DEBUG_SLAB
@@ -1291,6 +1290,7 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struc=
t slabinfo *info)
 	}
 }
=20
+
 static void cache_show(struct kmem_cache *s, struct seq_file *m)
 {
 	struct slabinfo sinfo;
@@ -1300,13 +1300,13 @@ static void cache_show(struct kmem_cache *s, struct=
 seq_file *m)
=20
 	memcg_accumulate_slabinfo(s, &sinfo);
=20
-	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
+	seq_printf(m, "%-30s %13lu %10lu %9u %12u %14d",
 		   cache_name(s), sinfo.active_objs, sinfo.num_objs, s->size,
 		   sinfo.objects_per_slab, (1 << sinfo.cache_order));
=20
-	seq_printf(m, " : tunables %4u %4u %4u",
+	seq_printf(m, " : tunables %7u %12u %14u",
 		   sinfo.limit, sinfo.batchcount, sinfo.shared);
-	seq_printf(m, " : slabdata %6lu %6lu %6lu",
+	seq_printf(m, " : slabdata %14lu %11lu %13lu",
 		   sinfo.active_slabs, sinfo.num_slabs, sinfo.shared_avail);
 	slabinfo_show_stats(m, s);
 	seq_putc(m, '\n');
--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
