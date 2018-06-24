Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 531706B0005
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 14:25:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x203-v6so3142908wmg.8
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 11:25:39 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id t132-v6si329481wmb.31.2018.06.24.11.25.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 24 Jun 2018 11:25:37 -0700 (PDT)
From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mm, swap: make swap_slots_cache_mutex and swap_slots_cache_enable_mutex static
Date: Sun, 24 Jun 2018 19:25:36 +0100
Message-Id: <20180624182536.4937-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The mutexes swap_slots_cache_mutex and swap_slots_cache_enable_mutex are
local to the source and do not need to be in global scope, so make them
static.

Cleans up sparse warnings:
symbol 'swap_slots_cache_mutex' was not declared. Should it be static?
symbol 'swap_slots_cache_enable_mutex' was not declared. Should it be
static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 mm/swap_slots.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index a791411fed71..008ccb22fee6 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -38,9 +38,9 @@ static DEFINE_PER_CPU(struct swap_slots_cache, swp_slots);
 static bool	swap_slot_cache_active;
 bool	swap_slot_cache_enabled;
 static bool	swap_slot_cache_initialized;
-DEFINE_MUTEX(swap_slots_cache_mutex);
+static DEFINE_MUTEX(swap_slots_cache_mutex);
 /* Serialize swap slots cache enable/disable operations */
-DEFINE_MUTEX(swap_slots_cache_enable_mutex);
+static DEFINE_MUTEX(swap_slots_cache_enable_mutex);
 
 static void __drain_swap_slots_cache(unsigned int type);
 static void deactivate_swap_slots_cache(void);
-- 
2.17.0
