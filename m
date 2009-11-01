Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 214C36B007E
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 10:13:09 -0500 (EST)
Date: Mon, 2 Nov 2009 00:13:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCHv2 5/5][nit fix] vmscan Make consistent of reclaim bale out between do_try_to_free_page and shrink_zone
In-Reply-To: <20091101234614.F401.A69D9226@jp.fujitsu.com>
References: <20091101234614.F401.A69D9226@jp.fujitsu.com>
Message-Id: <20091102001210.F40D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Fix small inconsistent of ">" and ">=".

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7bdf4f0..e6ea011 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1632,7 +1632,7 @@ static void shrink_zone(int priority, struct zone *zone,
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed > nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
 	}
 
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
