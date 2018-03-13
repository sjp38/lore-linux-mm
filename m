Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC3086B000E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:26:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v8so8150260pgs.9
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:26:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f64-v6si140485plb.377.2018.03.13.06.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:26:44 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 01/61] mac80211_hwsim: Use DEFINE_IDA
Date: Tue, 13 Mar 2018 06:25:39 -0700
Message-Id: <20180313132639.17387-2-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is preferred to opencoding an IDA_INIT.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 7b6c3640a94f..8bffd6ebc03e 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -253,7 +253,7 @@ static inline void hwsim_clear_chanctx_magic(struct ieee80211_chanctx_conf *c)
 
 static unsigned int hwsim_net_id;
 
-static struct ida hwsim_netgroup_ida = IDA_INIT;
+static DEFINE_IDA(hwsim_netgroup_ida);
 
 struct hwsim_net {
 	int netgroup;
-- 
2.16.1
