Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 4C7B96B0081
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:06:38 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mm: memory_hotplug: fix build error
Date: Tue, 11 Dec 2012 16:05:58 +0800
Message-ID: <1355213158-4955-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: laijs@cn.fujitsu.com, wency@cn.fujitsu.com, jiang.liu@huawei.com, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

Fix below build error(and comment):
mm/memory_hotplug.c:646:14: error: =E2=80=98ZONE_HIGH=E2=80=99 undeclared=
 (first use in this
function)
mm/memory_hotplug.c:646:14: note: each undeclared identifier is reported
only once for each function it appears in
make[1]: *** [mm/memory_hotplug.o] Error 1

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/memory_hotplug.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ea71d0d..9e97530 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -636,14 +636,14 @@ static void node_states_check_changes_online(unsign=
ed long nr_pages,
 #ifdef CONFIG_HIGHMEM
 	/*
 	 * If we have movable node, node_states[N_HIGH_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_HIGH,
-	 * set zone_last to ZONE_HIGH.
+	 * contains nodes which have zones of 0...ZONE_HIGHMEM,
+	 * set zone_last to ZONE_HIGHMEM.
 	 *
 	 * If we don't have movable node, node_states[N_NORMAL_MEMORY]
 	 * contains nodes which have zones of 0...ZONE_MOVABLE,
 	 * set zone_last to ZONE_MOVABLE.
 	 */
-	zone_last =3D ZONE_HIGH;
+	zone_last =3D ZONE_HIGHMEM;
 	if (N_MEMORY =3D=3D N_HIGH_MEMORY)
 		zone_last =3D ZONE_MOVABLE;
=20
--=20
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
