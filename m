Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 449776B0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 00:22:22 -0500 (EST)
Message-ID: <5111E82E.90202@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 13:20:46 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 6/7] net: change type of netns_ipvs->sysctl_sync_qlen_max
References: <5111E612.4010907@cn.fujitsu.com>
In-Reply-To: <5111E612.4010907@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This member of struct netns_ipvs is calculated from nr_free_buffer_pages
so change its type to unsigned long in case of overflow.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/net/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 68c69d5..66e6c01 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -966,7 +966,7 @@ struct netns_ipvs {
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
 	int			sysctl_sync_ports;
-	int			sysctl_sync_qlen_max;
+	unsigned long		sysctl_sync_qlen_max;
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
