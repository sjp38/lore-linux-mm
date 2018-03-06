Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 669246B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 14:24:20 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id j6-v6so10203337pll.10
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 11:24:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s3si10087652pfi.32.2018.03.06.11.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 11:24:19 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v8 01/63] mac80211_hwsim: Use DEFINE_IDA
Date: Tue,  6 Mar 2018 11:23:11 -0800
Message-Id: <20180306192413.5499-2-willy@infradead.org>
In-Reply-To: <20180306192413.5499-1-willy@infradead.org>
References: <20180306192413.5499-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
