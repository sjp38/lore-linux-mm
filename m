Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 15 of 24] limit reclaim if enough pages have been freed
Message-Id: <94686cfcd27347e83a6a.1187786942@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:02 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID 94686cfcd27347e83a6aa145c77457ca6455366d
# Parent  dde19626aa495cd8a6fa6b14a4f195438c2039ba
limit reclaim if enough pages have been freed

No need to wipe out an huge chunk of the cache.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1043,6 +1043,8 @@ static unsigned long shrink_zone(int pri
 			nr_inactive -= nr_to_scan;
 			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
 								sc);
+			if (nr_reclaimed >= sc->swap_cluster_max)
+				break;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
