Date: Mon, 17 Nov 2008 15:23:46 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] vmscan: fix get_scan_ratio comment
Message-ID: <20081117152346.363d2145@bree.surriel.com>
In-Reply-To: <4921BDC5.4090303@redhat.com>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081115210039.537f59f5.akpm@linux-foundation.org>
	<alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	<49208E9A.5080801@redhat.com>
	<20081116204720.1b8cbe18.akpm@linux-foundation.org>
	<20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
	<20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org>
	<alpine.LFD.2.00.0811170830320.3468@nehalem.linux-foundation.org>
	<4921A1AF.1070909@redhat.com>
	<alpine.LFD.2.00.0811170904160.3468@nehalem.linux-foundation.org>
	<4921A706.9030501@redhat.com>
	<alpine.LFD.2.00.0811170932390.3468@nehalem.linux-foundation.org>
	<4921BDC5.4090303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

Fix the old comment on the scan ratio calculations.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6.28-rc5/mm/vmscan.c
===================================================================
--- linux-2.6.28-rc5.orig/mm/vmscan.c	2008-11-16 17:47:13.000000000 -0500
+++ linux-2.6.28-rc5/mm/vmscan.c	2008-11-17 15:22:22.000000000 -0500
@@ -1386,9 +1386,9 @@ static void get_scan_ratio(struct zone *
 	file_prio = 200 - sc->swappiness;
 
 	/*
-	 *                  anon       recent_rotated[0]
-	 * %anon = 100 * ----------- / ----------------- * IO cost
-	 *               anon + file      rotate_sum
+	 * The amount of pressure on anon vs file pages is inversely
+	 * proportional to the fraction of recently scanned pages on
+	 * each list that were recently referenced and in active use.
 	 */
 	ap = (anon_prio + 1) * (zone->recent_scanned[0] + 1);
 	ap /= zone->recent_rotated[0] + 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
