Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E01DA6B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 14:37:49 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id n2so12876943wrb.7
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 11:37:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b66si6083294wmg.161.2018.02.05.11.37.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Feb 2018 11:37:48 -0800 (PST)
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 9D51DAD03
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 19:37:47 +0000 (UTC)
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: [PATCH] mm: Remove unused WB_REASON_FREE_MORE_MEM
Date: Mon,  5 Feb 2018 13:37:23 -0600
Message-Id: <20180205193723.26928-1-rgoldwyn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Goldwyn Rodrigues <rgoldwyn@suse.com>

From: Goldwyn Rodrigues <rgoldwyn@suse.com>

Signed-off-by: Goldwyn Rodrigues <rgoldwyn@suse.com>
---
 include/linux/backing-dev-defs.h | 1 -
 include/trace/events/writeback.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index bfe86b54f6c1..cdd25d735bf8 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -54,7 +54,6 @@ enum wb_reason {
 	WB_REASON_SYNC,
 	WB_REASON_PERIODIC,
 	WB_REASON_LAPTOP_TIMER,
-	WB_REASON_FREE_MORE_MEM,
 	WB_REASON_FS_FREE_SPACE,
 	/*
 	 * There is no bdi forker thread any more and works are done
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 32db72c7c055..5c45bc2db7e8 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -36,7 +36,6 @@
 	EM( WB_REASON_SYNC,			"sync")			\
 	EM( WB_REASON_PERIODIC,			"periodic")		\
 	EM( WB_REASON_LAPTOP_TIMER,		"laptop_timer")		\
-	EM( WB_REASON_FREE_MORE_MEM,		"free_more_memory")	\
 	EM( WB_REASON_FS_FREE_SPACE,		"fs_free_space")	\
 	EMe(WB_REASON_FORKER_THREAD,		"forker_thread")
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
