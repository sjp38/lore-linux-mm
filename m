Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1276C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 10:27:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95860206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 10:27:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DLbwRPHC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95860206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3169B6B0005; Fri, 26 Apr 2019 06:27:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C6596B0006; Fri, 26 Apr 2019 06:27:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5766B0007; Fri, 26 Apr 2019 06:27:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D860C6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:27:20 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c7so1746508plo.8
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:27:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=HsfT0F7SEIuKtfrkNzRXb7iLrCtKcJShqeMLFZsVtjY=;
        b=CuoqBa6/qZutgO99P5WCMVPDNgk0dff2Qm51l4R2zbYlzmnpQIiVXyIW7K57snnwNQ
         oJr2nZe19n2FOCBRVCRk4yuRyOMn47RAvKfa4BC3HjqjtmMWPv3AGpm5Tyf6UD+sexHr
         NRDTDyqRB+IV2ZHsXja90ZBcYxmw68hsoZRZD3u97ZET6a7XYscZZS6C3mV+kWLw9TPK
         GiRbKF7UFQv7Vl2E+l7XQTiRDew3G3ZhgczA/LxGou+OEpdjvzCdTAibjKiSPyTbc/Au
         etSXXedFwvh/OfLjyH/FyJ2OVIIfSeVNWMSsTPW3rIZZc189pax9C+vWoPQngILOYHiU
         CtjA==
X-Gm-Message-State: APjAAAVBpzGweupYkpC4V5r8apmb7MOafQ/7KkKj4HXLTZlHiQXtQoso
	bVOCGZYh+VLFJyW0P1EtfoLyni5sky03d5XtZaTlSmuKSee5ll/ZwB3F7u96fkp7t4XenVbxTBL
	/YUokXO8kfHGfpX2ioCGPpox/mNnLnBG4jABDyndTAW29jeyHiOpp0/zGwOw+WyUpTA==
X-Received: by 2002:a62:e118:: with SMTP id q24mr1885475pfh.95.1556274440431;
        Fri, 26 Apr 2019 03:27:20 -0700 (PDT)
X-Received: by 2002:a62:e118:: with SMTP id q24mr1885378pfh.95.1556274439019;
        Fri, 26 Apr 2019 03:27:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556274439; cv=none;
        d=google.com; s=arc-20160816;
        b=kiuXANR6yVl65gaqv2OFc0fkQ8JY0BHt+97T9A2FRnuWUoCL7rfUx15i8ZQ1klE9Yl
         lLw5x8Qi2sqhrC0N7OatFaoZQJhHNifGKQOOfxiOJEAz1NkAEWS2XJBk98gKMgpKanVe
         +RSCBqm70qTjIKESEdsTAm5HqpHA6Q98IKrABJuwPhUeJPszV9MsAUv8MJV88BT576Za
         A3To3QNaRbhZ+lYqmm/K2E48eQnZ/60TExA8e64r0FGYcQCsHYxf0Boecf2612a0+xZb
         PcDhOr+p/vGbHBCWoaRgWe4fECmpbmuR1Bfp5JJt/dXnwfsTalLKQlWOl06/sGaDV+pL
         SMvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=HsfT0F7SEIuKtfrkNzRXb7iLrCtKcJShqeMLFZsVtjY=;
        b=V7ionsBtxIkRL6ew9Pg70zy49uFI+qpScKpH+rTz/xYzqOFIjKZJKVT6uWeeIG7OAj
         bbin0FaioAa1/qkT9zP6za/8b5ZzZwjkuDthbrFQlx+nz3Qo3gPl4dcMcwqbDsEbJsh9
         pJ9I3MuzGz3uupztiOGr0yXHjczbwYrvS6NTINGUzPsW3ZyBSq+n6LXSTKzbSabT/sW4
         3m4w2wf+v4DP/r2azq/F/lbFQV0hjDZjdyOQ/dYVgN9v8z+m+t/D+RCmvEOHYrNXwXpV
         w11Ij+4I+uJ22YqvBUcwZuQeEpo9BuJWlwnRgxepHXFeWPVBn4THRK6y6wRYJzBSA9WG
         A50A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DLbwRPHC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1sor23749972plp.57.2019.04.26.03.27.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 03:27:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DLbwRPHC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=HsfT0F7SEIuKtfrkNzRXb7iLrCtKcJShqeMLFZsVtjY=;
        b=DLbwRPHCCBq2AY9Ju+1832yOc/qglRFP6wWbmqv++wmt7vke5hCZIXp9KmAHzoZUnM
         xz2VyeGcWiugxa1EvZMrwcNV9Mghp9QofZ58UBaMapYHK+7TcV/1YhgyzWiObXHwzlOe
         bX4tXz1g4l2kiOgSFVf6aPxxpvH2KlTBfmQQcDlUMqh3+wJi1bOuJL9jVY/ca9qaaGKv
         RhdNRYnSR4R2l1GUSHshbVKqw/C7Zqlo2HlKe0y8qQ0IdVGjx94/dFjuPEFVPPbDRSzH
         czL6L/MFTIEwJ8v7wHvCeA38AgGg5I91fYPeB0JTowMU8jw4a8oxDNn29i41p4m+aFgY
         tugg==
X-Google-Smtp-Source: APXvYqwtd6r9ekCJkqgFQfdyJXwvPZvIH8qmXgVf/Ak6rdmJ8aqH7Sr6YwOSEm47kLVzxmXFpMybUw==
X-Received: by 2002:a17:902:54c:: with SMTP id 70mr45630943plf.210.1556274438215;
        Fri, 26 Apr 2019 03:27:18 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id n65sm61297572pfb.160.2019.04.26.03.27.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 03:27:17 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: jack@suse.cz,
	mhocko@suse.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm/page-writeback: introduce tracepoint for wait_on_page_writeback
Date: Fri, 26 Apr 2019 18:26:42 +0800
Message-Id: <1556274402-19018-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recently there're some hungtasks on our server due to
wait_on_page_writeback, and we want to know the details of this
PG_writeback, i.e. this page is writing back to which device.
But it is not so convenient to get the details.

I think it would be better to introduce a tracepoint for diagnosing
the writeback details.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/linux/pagemap.h          | 10 +---------
 include/trace/events/writeback.h | 16 +++++++++++++++-
 mm/page-writeback.c              | 12 ++++++++++++
 3 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index f939e00..0f26c38 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -537,15 +537,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
 
 extern void put_and_wait_on_page_locked(struct page *page);
 
-/* 
- * Wait for a page to complete writeback
- */
-static inline void wait_on_page_writeback(struct page *page)
-{
-	if (PageWriteback(page))
-		wait_on_page_bit(page, PG_writeback);
-}
-
+void wait_on_page_writeback(struct page *page);
 extern void end_page_writeback(struct page *page);
 void wait_for_stable_page(struct page *page);
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 32db72c..aa7f3ae 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -53,7 +53,7 @@
 
 struct wb_writeback_work;
 
-TRACE_EVENT(writeback_dirty_page,
+DECLARE_EVENT_CLASS(writeback_page_template,
 
 	TP_PROTO(struct page *page, struct address_space *mapping),
 
@@ -79,6 +79,20 @@
 	)
 );
 
+DEFINE_EVENT(writeback_page_template, writeback_dirty_page,
+
+	TP_PROTO(struct page *page, struct address_space *mapping),
+
+	TP_ARGS(page, mapping)
+);
+
+DEFINE_EVENT(writeback_page_template, wait_on_page_writeback,
+
+	TP_PROTO(struct page *page, struct address_space *mapping),
+
+	TP_ARGS(page, mapping)
+);
+
 DECLARE_EVENT_CLASS(writeback_dirty_inode_template,
 
 	TP_PROTO(struct inode *inode, int flags),
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 9f61dfe..0765648 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2808,6 +2808,18 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 }
 EXPORT_SYMBOL(__test_set_page_writeback);
 
+/*
+ * Wait for a page to complete writeback
+ */
+void wait_on_page_writeback(struct page *page)
+{
+	if (PageWriteback(page)) {
+		trace_wait_on_page_writeback(page, page_mapping(page));
+		wait_on_page_bit(page, PG_writeback);
+	}
+}
+EXPORT_SYMBOL_GPL(wait_on_page_writeback);
+
 /**
  * wait_for_stable_page() - wait for writeback to finish, if necessary.
  * @page:	The page to wait on.
-- 
1.8.3.1

