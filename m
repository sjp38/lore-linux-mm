Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 1D1496B0038
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:46:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 12:35:45 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 055082CE8054
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 13:46:38 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r322XTvm2883922
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:33:29 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r322kard020126
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:46:37 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 5/8] staging: zcache: fix zcache writeback in debugfs
Date: Tue,  2 Apr 2013 10:46:17 +0800
Message-Id: <1364870780-16296-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

commit 9c0ad59ef ("zcache/debug: Use an array to initialize/use debugfs attributes") 
use an array to initialize/use debugfs attributes, .name = #x, .val = &zcache_##x.
For zcache writeback, this commit set .name = zcache_outstanding_writeback_pages and 
.name = zcache_writtenback_pages seperately, however, corresponding .val = 
&zcache_zcache_outstanding_writeback_pages and .val = &zcache_zcache_writtenback_pages,
which are not correct.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/debug.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/debug.c b/drivers/staging/zcache/debug.c
index 254dada..d2d1fdf 100644
--- a/drivers/staging/zcache/debug.c
+++ b/drivers/staging/zcache/debug.c
@@ -31,8 +31,8 @@ static struct debug_entry {
 	ATTR(eph_nonactive_puts_ignored),
 	ATTR(pers_nonactive_puts_ignored),
 #ifdef CONFIG_ZCACHE_WRITEBACK
-	ATTR(zcache_outstanding_writeback_pages),
-	ATTR(zcache_writtenback_pages),
+	ATTR(outstanding_writeback_pages),
+	ATTR(writtenback_pages),
 #endif
 };
 #undef ATTR
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
