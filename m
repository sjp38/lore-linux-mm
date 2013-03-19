Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 4AB9B6B003C
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 05:26:40 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 19 Mar 2013 19:21:27 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4C5B02BB0051
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:07 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2J9Q3Re57671742
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:03 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2J9Q6XS028045
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:07 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 4/8] staging: zcache: fix pers_pageframes|_max aren't exported in debugfs
Date: Tue, 19 Mar 2013 17:25:46 +0800
Message-Id: <1363685150-18303-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
