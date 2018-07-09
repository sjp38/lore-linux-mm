Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76FC96B0283
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:37:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x21-v6so2914874eds.2
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:37:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12-v6sor4091774eds.38.2018.07.09.01.37.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 01:37:04 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 06/12] mm: use for_each_if
Date: Mon,  9 Jul 2018 10:36:44 +0200
Message-Id: <20180709083650.23549-6-daniel.vetter@ffwll.ch>
In-Reply-To: <20180709083650.23549-1-daniel.vetter@ffwll.ch>
References: <20180709083650.23549-1-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Kemi Wang <kemi.wang@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, linux-mm@kvack.org

Avoids the inverted condition of the open-coded version.

Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>
Cc: Kemi Wang <kemi.wang@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Petr Tesarik <ptesarik@suse.com>
Cc: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Nikolay Borisov <nborisov@suse.com>
Cc: linux-mm@kvack.org
---
 include/linux/mmzone.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2dc52a..1bd5f4c72c8b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -940,9 +940,7 @@ extern struct zone *next_zone(struct zone *zone);
 	for (zone = (first_online_pgdat())->node_zones; \
 	     zone;					\
 	     zone = next_zone(zone))			\
-		if (!populated_zone(zone))		\
-			; /* do nothing */		\
-		else
+		for_each_if (populated_zone(zone))
 
 static inline struct zone *zonelist_zone(struct zoneref *zoneref)
 {
-- 
2.18.0
