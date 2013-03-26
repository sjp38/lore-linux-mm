Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id D3BA66B0140
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 13:49:34 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 26 Mar 2013 11:49:32 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2C7C03E4006F
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:46:48 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2QHkrNX125666
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:46:54 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2QHknG6019843
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:46:50 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 3/3] powerpc/mm/numa: use setup_nr_node_ids() instead of opencoding.
Date: Tue, 26 Mar 2013 10:46:02 -0700
Message-Id: <1364319962-30967-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1364319962-30967-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1364319962-30967-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index bba87ca..7574ae3 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -62,14 +62,11 @@ static int distance_lookup_table[MAX_NUMNODES][MAX_DISTANCE_REF_POINTS];
  */
 static void __init setup_node_to_cpumask_map(void)
 {
-	unsigned int node, num = 0;
+	unsigned int node;
 
 	/* setup nr_node_ids if not done yet */
-	if (nr_node_ids == MAX_NUMNODES) {
-		for_each_node_mask(node, node_possible_map)
-			num = node;
-		nr_node_ids = num + 1;
-	}
+	if (nr_node_ids == MAX_NUMNODES)
+		setup_nr_node_ids()
 
 	/* allocate the map */
 	for (node = 0; node < nr_node_ids; node++)
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
