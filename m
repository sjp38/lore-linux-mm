Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 284B86B00E7
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 17:49:22 -0400 (EDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 5/6] MAINTAINER: Add myself for the frontswap API
Date: Fri, 20 Apr 2012 17:44:14 -0400
Message-Id: <1334958255-6612-6-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
References: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, aarcange@redhat.com, dhowells@redhat.com, riel@redhat.com, JBeulich@novell.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2dcfca8..bc8905d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2876,6 +2876,13 @@ F:	Documentation/power/freezing-of-tasks.txt
 F:	include/linux/freezer.h
 F:	kernel/freezer.c
 
+FRONTSWAP API
+M:	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
+L:	linux-kernel@vger.kernel.org
+S:	Maintained
+F:	mm/frontswap.c
+F:	include/linux/frontswap.h
+
 FS-CACHE: LOCAL CACHING FOR NETWORK FILESYSTEMS
 M:	David Howells <dhowells@redhat.com>
 L:	linux-cachefs@redhat.com
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
