Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id C16136B0044
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:47:09 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 12:40:26 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 28901357804A
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 13:47:05 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r322kUOx3015146
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:46:30 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r322kY0U028089
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:46:34 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 4/8] staging: zcache: fix pers_pageframes|_max aren't exported in debugfs
Date: Tue,  2 Apr 2013 10:46:16 +0800
Message-Id: <1364870780-16296-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Before commit 9c0ad59ef ("zcache/debug: Use an array to initialize/use debugfs attributes"),
pers_pageframes|_max are exported in debugfs, but this commit forgot use array export 
pers_pageframes|_max. This patch add pers_pageframes|_max back.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/debug.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/zcache/debug.c b/drivers/staging/zcache/debug.c
index e951c64..254dada 100644
--- a/drivers/staging/zcache/debug.c
+++ b/drivers/staging/zcache/debug.c
@@ -21,6 +21,7 @@ static struct debug_entry {
 	ATTR(pers_ate_eph), ATTR(pers_ate_eph_failed),
 	ATTR(evicted_eph_zpages), ATTR(evicted_eph_pageframes),
 	ATTR(eph_pageframes), ATTR(eph_pageframes_max),
+	ATTR(pers_pageframes), ATTR(pers_pageframes_max),
 	ATTR(eph_zpages), ATTR(eph_zpages_max),
 	ATTR(pers_zpages), ATTR(pers_zpages_max),
 	ATTR(last_active_file_pageframes),
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
