Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 05A306B00EF
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:18:40 -0400 (EDT)
Received: by mail-gh0-f169.google.com with SMTP id r18so3001442ghr.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 02:18:40 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 6/6] MAINTAINERS: Added MEMPOLICY entry
Date: Mon, 11 Jun 2012 05:17:30 -0400
Message-Id: <1339406250-10169-7-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Christoph Lameter <cl@linux.com>
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
