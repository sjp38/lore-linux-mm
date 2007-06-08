Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 17E6F215DE
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:08:10 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 15 of 16] limit reclaim if enough pages have been freed
Message-Id: <31ef5d0bf924fb47da14.1181332993@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:13 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332962 -7200
# Node ID 31ef5d0bf924fb47da144321f692f4fefebf5cf5
# Parent  dbd70ffd95f34cd12f1fd2f05a9cc0f9a50edb4a
limit reclaim if enough pages have been freed

No need to wipe out an huge chunk of the cache.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -938,6 +938,8 @@ static unsigned long shrink_zone(int pri
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
