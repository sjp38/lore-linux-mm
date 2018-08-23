Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8385D6B2936
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:59:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d10-v6so2225225pll.22
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:59:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2-v6sor1123784pgj.305.2018.08.23.01.59.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 01:59:22 -0700 (PDT)
From: Weikang Shi <swkhack@gmail.com>
Subject: [PATCH] fs: fix local var type
Date: Thu, 23 Aug 2018 01:59:14 -0700
Message-Id: <1535014754-31918-1-git-send-email-swkhack@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: alexander.h.duyck@intel.com, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, my_email@gmail.com, Weikang Shi <swkhack@gmail.com>

In the seq_hex_dump function,the remaining variable is int, but it receive a type of size_t argument.
So I change the type of remaining

Signed-off-by: Weikang Shi <swkhack@gmail.com>
---
 fs/seq_file.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/seq_file.c b/fs/seq_file.c
index 1dea7a8..d0e8bec 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -847,7 +847,8 @@ void seq_hex_dump(struct seq_file *m, const char *prefix_str, int prefix_type,
 		  bool ascii)
 {
 	const u8 *ptr = buf;
-	int i, linelen, remaining = len;
+	int i, linelen;
+	size_t remaining = len;
 	char *buffer;
 	size_t size;
 	int ret;
-- 
2.7.4
