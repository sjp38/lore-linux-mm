Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 978A56B005A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 06:46:30 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/9] Revert "mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix"
Date: Fri, 21 Sep 2012 11:46:16 +0100
Message-Id: <1348224383-1499-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1348224383-1499-1-git-send-email-mgorman@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This reverts
mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix
as it is replaced by a later patch in the series.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 4a77b4b..1c873bb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -907,7 +907,8 @@ static unsigned long compact_zone_order(struct zone *zone,
 	INIT_LIST_HEAD(&cc.migratepages);
 
 	ret = compact_zone(zone, &cc);
-	*contended = cc.contended;
+	if (contended)
+		*contended = cc.contended;
 	return ret;
 }
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
