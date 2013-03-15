Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 19B7F6B003A
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:35:21 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 15 Mar 2013 08:02:56 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id BF3F0125804F
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 08:06:20 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2F2ZDcY6881668
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 08:05:13 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2F2ZFEC031105
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 13:35:15 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 5/5] clean TODO list
Date: Fri, 15 Mar 2013 10:34:20 +0800
Message-Id: <1363314860-22731-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Cleanup TODO list since support zero-filled pages more efficiently has 
already done by this patchset.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/TODO |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/TODO b/drivers/staging/zcache/TODO
index c1e26d4..9e755d3 100644
--- a/drivers/staging/zcache/TODO
+++ b/drivers/staging/zcache/TODO
@@ -65,5 +65,4 @@ ZCACHE FUTURE NEW FUNCTIONALITY
 
 A. Support zsmalloc as an alternative high-density allocator
     (See https://lkml.org/lkml/2013/1/23/511)
-B. Support zero-filled pages more efficiently
-C. Possibly support three zbuds per pageframe when space allows
+B. Possibly support three zbuds per pageframe when space allows
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
