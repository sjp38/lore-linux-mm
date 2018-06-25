Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2645B6B026F
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 13:15:31 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id e17-v6so4282302uam.21
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:15:31 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f4-v6sor1961858vkb.171.2018.06.25.10.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 10:15:30 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 25 Jun 2018 10:15:26 -0700
Message-Id: <20180625171526.173483-1-gthelen@google.com>
Subject: [PATCH] writeback: update stale account_page_redirty() comment
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

commit 93f78d882865 ("writeback: move backing_dev_info->bdi_stat[] into
bdi_writeback") replaced BDI_DIRTIED with WB_DIRTIED in
account_page_redirty().  Update comment to track that change.
  BDI_DIRTIED => WB_DIRTIED
  BDI_WRITTEN => WB_WRITTEN

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 337c6afb3345..6551d3b0dc30 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2490,8 +2490,8 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers);
 
 /*
  * Call this whenever redirtying a page, to de-account the dirty counters
- * (NR_DIRTIED, BDI_DIRTIED, tsk->nr_dirtied), so that they match the written
- * counters (NR_WRITTEN, BDI_WRITTEN) in long term. The mismatches will lead to
+ * (NR_DIRTIED, WB_DIRTIED, tsk->nr_dirtied), so that they match the written
+ * counters (NR_WRITTEN, WB_WRITTEN) in long term. The mismatches will lead to
  * systematic errors in balanced_dirty_ratelimit and the dirty pages position
  * control.
  */
-- 
2.18.0.rc2.346.g013aa6912e-goog
