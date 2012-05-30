Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7FF1A6B0071
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:03:25 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id ey12so4077167vbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 02:03:25 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 6/6] MAINTAINERS: Added MEMPOLICY entry
Date: Wed, 30 May 2012 05:02:09 -0400
Message-Id: <1338368529-21784-7-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index a246490..6f4a8e2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4467,6 +4467,13 @@ F:	drivers/mtd/
 F:	include/linux/mtd/
 F:	include/mtd/
 
+MEMPOLICY
+M:	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	include/linux/mempolicy.h
+F:	mm/mempolicy.c
+
 MICROBLAZE ARCHITECTURE
 M:	Michal Simek <monstr@monstr.eu>
 L:	microblaze-uclinux@itee.uq.edu.au (moderated for non-subscribers)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
