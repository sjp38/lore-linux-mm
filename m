Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD79B6B0285
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 04:37:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v9-v6so1360954pfn.6
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 01:37:34 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50136.outbound.protection.outlook.com. [40.107.5.136])
        by mx.google.com with ESMTPS id b4-v6si13354156pgw.50.2018.07.09.01.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Jul 2018 01:37:33 -0700 (PDT)
Subject: [PATCH v9 01/17] list_lru: Combine code under the same define
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 09 Jul 2018 11:37:23 +0300
Message-ID: <153112544321.4097.774414812050671572.stgit@localhost.localdomain>
In-Reply-To: <153112469064.4097.2581798353485457328.stgit@localhost.localdomain>
References: <153112469064.4097.2581798353485457328.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com

These two pairs of blocks of code are under
the same #ifdef #else #endif.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 mm/list_lru.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index db679a057f46..b65e0b9b0646 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -29,17 +29,7 @@ static void list_lru_unregister(struct list_lru *lru)
 	list_del(&lru->list);
 	mutex_unlock(&list_lrus_mutex);
 }
-#else
-static void list_lru_register(struct list_lru *lru)
-{
-}
-
-static void list_lru_unregister(struct list_lru *lru)
-{
-}
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
 	/*
@@ -89,6 +79,14 @@ list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
 	return list_lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
 }
 #else
+static void list_lru_register(struct list_lru *lru)
+{
+}
+
+static void list_lru_unregister(struct list_lru *lru)
+{
+}
+
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
 	return false;
