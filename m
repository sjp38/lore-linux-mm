Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 299D76B0031
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:29:50 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 14 Jun 2013 15:29:49 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 83BABC90026
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:29:44 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5EJSN5v339542
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:28:23 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5EJSMh0014923
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 13:28:23 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH] MAINTAINERS: add zswap and zbud maintainer
Date: Fri, 14 Jun 2013 14:28:20 -0500
Message-Id: <1371238100-4621-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, Cesar Eduardo Barros <cesarb@cesarb.net>, "David S. Miller" <davem@davemloft.net>, Hans Verkuil <hans.verkuil@cisco.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch adds maintainer information for zswap and zbud
into the MAINTAINERS file.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 MAINTAINERS |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 8bdd7a7..8c5897e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9011,6 +9011,13 @@ F:	Documentation/networking/z8530drv.txt
 F:	drivers/net/hamradio/*scc.c
 F:	drivers/net/hamradio/z8530.h
 
+ZBUD COMPRESSED PAGE ALLOCATOR
+M:	Seth Jennings <sjenning@linux.vnet.ibm.com>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	mm/zbud.c
+F:	include/linux/zbud.h
+
 ZD1211RW WIRELESS DRIVER
 M:	Daniel Drake <dsd@gentoo.org>
 M:	Ulrich Kunitz <kune@deine-taler.de>
@@ -9033,6 +9040,12 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
 F:	drivers/tty/serial/zs.*
 
+ZSWAP COMPRESSED SWAP CACHING
+M:	Seth Jennings <sjenning@linux.vnet.ibm.com>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	mm/zswap.c
+
 THE REST
 M:	Linus Torvalds <torvalds@linux-foundation.org>
 L:	linux-kernel@vger.kernel.org
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
