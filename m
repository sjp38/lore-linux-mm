Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 797DB6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 10:08:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 82so905286pfs.8
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 07:08:29 -0800 (PST)
Received: from smtp.gentoo.org (dev.gentoo.org. [2001:470:ea4a:1:5054:ff:fec7:86e4])
        by mx.google.com with ESMTPS id e4si6336547pgn.428.2018.01.18.07.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 07:08:28 -0800 (PST)
From: =?UTF-8?q?Christopher=20D=C3=ADaz=20Riveros?= <chrisadr@gentoo.org>
Subject: [PATCH-next] MEMCG: memcontrol: make local symbol static
Date: Thu, 18 Jan 2018 10:08:05 -0500
Message-Id: <20180118150805.18521-1-chrisadr@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: =?UTF-8?q?Christopher=20D=C3=ADaz=20Riveros?= <chrisadr@gentoo.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

Fixes the following sparse warning:

mm/memcontrol.c:1097:14: warning:
  symbol 'memcg1_stats' was not declared. Should it be static?

Signed-off-by: Christopher DA-az Riveros <chrisadr@gentoo.org>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c3d1eaef752d..396674fd97ef 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1094,7 +1094,7 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 	return false;
 }
 
-unsigned int memcg1_stats[] = {
+static unsigned int memcg1_stats[] = {
 	MEMCG_CACHE,
 	MEMCG_RSS,
 	MEMCG_RSS_HUGE,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
