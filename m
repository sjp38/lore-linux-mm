Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 302866B0253
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 14:33:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 64so9810033pgc.17
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:33:47 -0800 (PST)
Received: from smtp.gentoo.org (woodpecker.gentoo.org. [2001:470:ea4a:1:5054:ff:fec7:86e4])
        by mx.google.com with ESMTPS id t24si3303430pfe.136.2018.01.18.11.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 11:33:45 -0800 (PST)
From: =?UTF-8?q?Christopher=20D=C3=ADaz=20Riveros?= <chrisadr@gentoo.org>
Subject: [PATCH-next] MEMCG: memcontrol: make local symbol static
Date: Thu, 18 Jan 2018 14:33:27 -0500
Message-Id: <20180118193327.14200-1-chrisadr@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: =?UTF-8?q?Christopher=20D=C3=ADaz=20Riveros?= <chrisadr@gentoo.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Fixes the following sparse warning:

mm/memcontrol.c:1097:14: warning:
  symbol 'memcg1_stats' was not declared. Should it be static?

Signed-off-by: Christopher DA-az Riveros <chrisadr@gentoo.org>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c3d1eaef752d..c992491dfb03 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1094,7 +1094,7 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 	return false;
 }
 
-unsigned int memcg1_stats[] = {
+static const unsigned int memcg1_stats[] = {
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
