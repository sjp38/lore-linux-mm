Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 10 of 13] limit reclaim if enough pages have been freed
Message-Id: <0a13c24681cf4851555c.1199778641@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:41 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470022 -3600
# Node ID 0a13c24681cf4851555c87358fc2ec2465f9ef39
# Parent  6c433e92ef119dd39893c6b54e41154866c32ef8
limit reclaim if enough pages have been freed

No need to wipe out an huge chunk of the cache.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1149,6 +1149,8 @@ static unsigned long shrink_zone(int pri
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
