From: Bo Liu <bo-liu@hotmail.com>
Subject: [PATCH] mv clear node_load[] to __build_all_zonelists()
Date: Thu, 6 Aug 2009 18:44:40 +0800
Message-ID: <COL115-W869FC30815A7D5B7A63339F0A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 291356B005C
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 06:44:40 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
List-Id: linux-mm.kvack.org


 If node_load[] is cleared everytime build_zonelists() is called=2Cnode_loa=
d[]
 will have no help to find the next node that should appear in the given no=
de's
 fallback list.
 Signed-off-by: Bob Liu=20
---
 mm/page_alloc.c |    2 +-
 1 files changed=2C 1 insertions(+)=2C 1 deletions(-)
=20
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d052abb..72f7345 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2544=2C7 +2544=2C6 @@ static void build_zonelists(pg_data_t *pgdat)
 	prev_node =3D local_node=3B
 	nodes_clear(used_mask)=3B
=20
-	memset(node_load=2C 0=2C sizeof(node_load))=3B
 	memset(node_order=2C 0=2C sizeof(node_order))=3B
 	j =3D 0=3B
=20
@@ -2653=2C6 +2652=2C7 @@ static int __build_all_zonelists(void *dummy)
 {
 	int nid=3B
=20
+	memset(node_load=2C 0=2C sizeof(node_load))=3B
 	for_each_online_node(nid) {
 		pg_data_t *pgdat =3D NODE_DATA(nid)=3B




_________________________________________________________________
Drag n=92 drop=97Get easy photo sharing with Windows Live=99 Photos.

http://www.microsoft.com/windows/windowslive/products/photos.aspx=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
