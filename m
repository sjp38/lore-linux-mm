Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 034C9C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:53:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD4B7214AF
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 15:53:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kAOn5Shr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD4B7214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BC086B0003; Tue, 17 Sep 2019 11:53:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 592F96B0005; Tue, 17 Sep 2019 11:53:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AA616B0006; Tue, 17 Sep 2019 11:53:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 2BFE86B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:53:57 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BB87883E2
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:53:56 +0000 (UTC)
X-FDA: 75944858472.14.fuel85_5c98c3774670e
X-HE-Tag: fuel85_5c98c3774670e
X-Filterd-Recvd-Size: 4799
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com [209.85.208.195])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 15:53:56 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id 7so4062361ljw.7
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 08:53:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=2YOj06cPPvgsZx9maFNFvfyY5twtTMJtLzahT6UKWkM=;
        b=kAOn5ShrNvK4JRjqibsxIgC3tnVF3yLFi1pJnhx52obG35TjwggxRBvh7USQv2jDlh
         SaXa5YI0QDhVDM0XOtk2uIbz6dnWhZwPCnKx7aj/1dv5EwEEJhm24G5CSugX93SklLME
         6ClLDZZvexTAhqhrhsnupobLStLlEZEIn0lVbIjpFCQ+VTRgmAS1lf0XFPM2tscrZIWi
         MUPhhPUnjkeAkQEzIvs8qXv9f+zwOWPRxKva89MthTxTIRNnnQvcXmOSlh0xq9pm+ysI
         wVLuqnzz39t3+DrPVleBmISEaUxgBdqhprHTOH9K/NQ+ozoqAHxtEJQnXnZIMvvLDbEd
         Ye2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=2YOj06cPPvgsZx9maFNFvfyY5twtTMJtLzahT6UKWkM=;
        b=YA1Hv1K5/yGMV7w+CARBLyhE12HNcpXjrw9Z3/PUkFWuEbiVMTkKeiT8Mo59bQetpK
         9+yG0CTdJh+2fLXyhkk7M0NjDa1WCkv5PxTXLNSo6D4bIxVa4uLQr2X5WkPoSIK6DFvX
         zJQ4rpE/dLIW4nu2xJkqriX+Dy7bwjQ2EjrHpenhjxZ0TDiU1XTyVST0rFaZutBu6aUt
         PlgRhsu2bIHd6Fj9dEybXw+BD8/zb2YEj6qjgWqO5FgKqOUmW6w9tC98aB91IgUKpm+H
         NjX3ZDsSBctU0antT68Gx1cekAF1UoIlDvdhnYsrPUsGqXYOa8KcC6XCzQnXIFih5PmV
         7yuA==
X-Gm-Message-State: APjAAAUDw6r73FKdxSaOjQGO98EzbKe2nBJT89xXRik0ao3wWhIOZPLa
	paRr23hTCvEIK1skrcrZYatFTOFsG0ecyw==
X-Google-Smtp-Source: APXvYqxInzgwwA/H7snjGtaKT2ZKQl55koT6+1i82eeg1Fid52kHKD8WfWEvLiVsSbaoNPgPXI6hVA==
X-Received: by 2002:a2e:9d0d:: with SMTP id t13mr2297429lji.169.1568735634420;
        Tue, 17 Sep 2019 08:53:54 -0700 (PDT)
Received: from vitaly-Dell-System-XPS-L322X ([188.150.241.161])
        by smtp.gmail.com with ESMTPSA id x76sm604083ljb.81.2019.09.17.08.53.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Sep 2019 08:53:53 -0700 (PDT)
Date: Tue, 17 Sep 2019 18:53:52 +0300
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, Andrew Morton
 <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Vlastimil Babka <vbabka@suse.cz>,
 markus.linnala@gmail.com
Subject: [PATCH] z3fold: fix memory leak in kmem cache
Message-Id: <20190917185352.44cf285d3ebd9e64548de5de@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently there is a leak in init_z3fold_page() -- it allocates
handles from kmem cache even for headless pages, but then they are
never used and never freed, so eventually kmem cache may get
exhausted. This patch provides a fix for that.

Reported-by: Markus Linnala <markus.linnala@gmail.com>
Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 6397725b5ec6..7dffef2599c3 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -301,14 +301,11 @@ static void z3fold_unregister_migration(struct z3fold_pool *pool)
  }
 
 /* Initializes the z3fold header of a newly allocated z3fold page */
-static struct z3fold_header *init_z3fold_page(struct page *page,
+static struct z3fold_header *init_z3fold_page(struct page *page, bool headless,
 					struct z3fold_pool *pool, gfp_t gfp)
 {
 	struct z3fold_header *zhdr = page_address(page);
-	struct z3fold_buddy_slots *slots = alloc_slots(pool, gfp);
-
-	if (!slots)
-		return NULL;
+	struct z3fold_buddy_slots *slots;
 
 	INIT_LIST_HEAD(&page->lru);
 	clear_bit(PAGE_HEADLESS, &page->private);
@@ -316,6 +313,12 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 	clear_bit(NEEDS_COMPACTING, &page->private);
 	clear_bit(PAGE_STALE, &page->private);
 	clear_bit(PAGE_CLAIMED, &page->private);
+	if (headless)
+		return zhdr;
+
+	slots = alloc_slots(pool, gfp);
+	if (!slots)
+		return NULL;
 
 	spin_lock_init(&zhdr->page_lock);
 	kref_init(&zhdr->refcount);
@@ -962,7 +965,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	if (!page)
 		return -ENOMEM;
 
-	zhdr = init_z3fold_page(page, pool, gfp);
+	zhdr = init_z3fold_page(page, bud == HEADLESS, pool, gfp);
 	if (!zhdr) {
 		__free_page(page);
 		return -ENOMEM;
-- 
2.17.1

