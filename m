Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0B9156B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 19:14:06 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 9 Jan 2013 19:14:05 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id F26636E803F
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 19:14:01 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0A0E2Af298252
	for <linux-mm@kvack.org>; Wed, 9 Jan 2013 19:14:02 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0A0E2Bo002365
	for <linux-mm@kvack.org>; Wed, 9 Jan 2013 22:14:02 -0200
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH] MAINTAINERS: mm: add additional include files to listing
Date: Wed,  9 Jan 2013 16:13:38 -0800
Message-Id: <1357776818-13421-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>

Add gfp.h, mmzone.h, memory_hotplug.h & vmalloc.h to the "MEMORY
MANAGMENT" section so scripts/get_maintainer.pl can do a better job of
making recommendations.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---

Missed sending this to linux-mm due to a screwed up alias, sorry.

 MAINTAINERS | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 915564e..e77ef28 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5003,6 +5003,10 @@ L:	linux-mm@kvack.org
 W:	http://www.linux-mm.org
 S:	Maintained
 F:	include/linux/mm.h
+F:	include/linux/gfp.h
+F:	include/linux/mmzone.h
+F:	include/linux/memory_hotplug.h
+F:	include/linux/vmalloc.h
 F:	mm/
 
 MEMORY RESOURCE CONTROLLER
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
