Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id F0CF36B005D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:48:07 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 30 Jul 2012 15:48:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B6B016E8062
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:48:03 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6UJm2VL339216
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:48:02 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6UJnE82022348
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 13:49:14 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH][TRIVIAL] mm/frontswap: fix uninit'ed variable warning
Date: Mon, 30 Jul 2012 14:47:44 -0500
Message-Id: <1343677664-26665-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, trivial@kernel.org

Fixes uninitialized variable warning on 'type' in frontswap_shrink().
type is set before use by __frontswap_unuse_pages() called by
__frontswap_shrink() called by frontswap_shrink() before use by
try_to_unuse().

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
Based on next-20120730

 mm/frontswap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 6b3e71a..89dc399 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -292,7 +292,7 @@ static int __frontswap_shrink(unsigned long target_pages,
 void frontswap_shrink(unsigned long target_pages)
 {
 	unsigned long pages_to_unuse = 0;
-	int type, ret;
+	int uninitialized_var(type), ret;
 
 	/*
 	 * we don't want to hold swap_lock while doing a very
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
