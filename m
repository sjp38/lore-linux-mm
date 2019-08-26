Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90BB7C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 16:07:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5377420850
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 16:07:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gX5n0n0I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5377420850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 806C16B05B4; Mon, 26 Aug 2019 12:07:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E0CE6B05B5; Mon, 26 Aug 2019 12:07:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65BE96B05B6; Mon, 26 Aug 2019 12:07:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7B16B05B4
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:07:12 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CBEB7181AC9B4
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:07:11 +0000 (UTC)
X-FDA: 75865058262.27.wish24_5bdbeef973503
X-HE-Tag: wish24_5bdbeef973503
X-Filterd-Recvd-Size: 6918
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:07:11 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id 44so18344554qtg.11
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 09:07:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=sbi9AtPpKs90xX0XCzYWXMGLwoRRPZP34bqUM0NUXLs=;
        b=gX5n0n0Iya2r+6HfxSBgduwjqnM9PRtJlmoEm5ghngBsve/UtQYFYtPDwNviTIYOMH
         yLHoMeNJ+DWQ0bdNx4cvSVgcN681dV36+OkH/g1jKJgRguOi7VsP0NlyTZAz7cNUZOE6
         zqnuyTGB/QvBuFExLTGnei+AosOZ6sQ0y8LkGtkVWGqoLaIqdMokGxmf43BnVYTMWOsm
         TfgrfDI+kUfbZopDzIk1PUoIxNGEh7GWOOExZRBb6f7AdZPpR69VNoZkY4jlUDeGLJQo
         pcOBl6W9Exf/K3YN+IZmyKLnwa/O+zqQugMqiuDEyPBkAwPlHoZuAITEWOR87u2+0DCW
         ok0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references;
        bh=sbi9AtPpKs90xX0XCzYWXMGLwoRRPZP34bqUM0NUXLs=;
        b=YJX9WhQNTmaDel8gI4OlZIFzU9UV9EYUJlo1aTcvI/NSpPVg4XeuJXCxMHcOkZ5Bun
         ln5T/VfBqL3jlYJMia6WlgWG2JiWqFDYZTrcf/HevM4m5H9PrgxNVPwC0T5pjyVXESoI
         9cM0ENvdJ3DtvqjCgFBRrgnrlkZRFA8rMXvlO2u8FywmeohDACB6GyWQOPTdfBoqxyRG
         XWvHW5qgF4/zcMK1YI5N1cG/U41HgKPzrQdBysTRkAr5CAMS25dcsp40e1hT0BqyaSsW
         +/jp8wqtGnCmgt3Nt9uX3xWhRB/QTv5M6Ujty4YUjQMIaveMr10YcDH7+tYeOGgxLWVq
         Nl4Q==
X-Gm-Message-State: APjAAAVX5nF1I9of83WUH5/xqhGWNcOCQgqB0YN/sw5me1ntDbwnJANe
	6aDZwURHM2oOvC4cEwGUb59loAfj
X-Google-Smtp-Source: APXvYqwfRmoFj279L2wsJx3QYrn8JRDZ4xVVrNIXLn3zjcDpszmBL7Yzn1lB3z9lIiUyrSDzWNyx1Q==
X-Received: by 2002:ac8:4789:: with SMTP id k9mr18184801qtq.41.1566835630468;
        Mon, 26 Aug 2019 09:07:10 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::d081])
        by smtp.gmail.com with ESMTPSA id 131sm6410446qkn.7.2019.08.26.09.07.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Aug 2019 09:07:09 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk,
	jack@suse.cz,
	hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	guro@fb.com,
	akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/5] writeback: Separate out wb_get_lookup() from wb_get_create()
Date: Mon, 26 Aug 2019 09:06:54 -0700
Message-Id: <20190826160656.870307-4-tj@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190826160656.870307-1-tj@kernel.org>
References: <20190826160656.870307-1-tj@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Separate out wb_get_lookup() which doesn't try to create one if there
isn't already one from wb_get_create().  This will be used by later
patches.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h |  2 ++
 mm/backing-dev.c            | 55 +++++++++++++++++++++++++------------
 2 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 84cdcfbc763f..97967ce06de3 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -230,6 +230,8 @@ static inline int bdi_sched_wait(void *word)
 struct bdi_writeback_congested *
 wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp);
 void wb_congested_put(struct bdi_writeback_congested *congested);
+struct bdi_writeback *wb_get_lookup(struct backing_dev_info *bdi,
+				    struct cgroup_subsys_state *memcg_css);
 struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 				    struct cgroup_subsys_state *memcg_css,
 				    gfp_t gfp);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 612aa7c5ddbd..d9daa3e422d0 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -618,13 +618,12 @@ static int cgwb_create(struct backing_dev_info *bdi,
 }
 
 /**
- * wb_get_create - get wb for a given memcg, create if necessary
+ * wb_get_lookup - get wb for a given memcg
  * @bdi: target bdi
  * @memcg_css: cgroup_subsys_state of the target memcg (must have positive ref)
- * @gfp: allocation mask to use
  *
- * Try to get the wb for @memcg_css on @bdi.  If it doesn't exist, try to
- * create one.  The returned wb has its refcount incremented.
+ * Try to get the wb for @memcg_css on @bdi.  The returned wb has its
+ * refcount incremented.
  *
  * This function uses css_get() on @memcg_css and thus expects its refcnt
  * to be positive on invocation.  IOW, rcu_read_lock() protection on
@@ -641,6 +640,39 @@ static int cgwb_create(struct backing_dev_info *bdi,
  * each lookup.  On mismatch, the existing wb is discarded and a new one is
  * created.
  */
+struct bdi_writeback *wb_get_lookup(struct backing_dev_info *bdi,
+				    struct cgroup_subsys_state *memcg_css)
+{
+	struct bdi_writeback *wb;
+
+	if (!memcg_css->parent)
+		return &bdi->wb;
+
+	rcu_read_lock();
+	wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
+	if (wb) {
+		struct cgroup_subsys_state *blkcg_css;
+
+		/* see whether the blkcg association has changed */
+		blkcg_css = cgroup_get_e_css(memcg_css->cgroup, &io_cgrp_subsys);
+		if (unlikely(wb->blkcg_css != blkcg_css || !wb_tryget(wb)))
+			wb = NULL;
+		css_put(blkcg_css);
+	}
+	rcu_read_unlock();
+
+	return wb;
+}
+
+/**
+ * wb_get_create - get wb for a given memcg, create if necessary
+ * @bdi: target bdi
+ * @memcg_css: cgroup_subsys_state of the target memcg (must have positive ref)
+ * @gfp: allocation mask to use
+ *
+ * Try to get the wb for @memcg_css on @bdi.  If it doesn't exist, try to
+ * create one.  See wb_get_lookup() for more details.
+ */
 struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 				    struct cgroup_subsys_state *memcg_css,
 				    gfp_t gfp)
@@ -653,20 +685,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 		return &bdi->wb;
 
 	do {
-		rcu_read_lock();
-		wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
-		if (wb) {
-			struct cgroup_subsys_state *blkcg_css;
-
-			/* see whether the blkcg association has changed */
-			blkcg_css = cgroup_get_e_css(memcg_css->cgroup,
-						     &io_cgrp_subsys);
-			if (unlikely(wb->blkcg_css != blkcg_css ||
-				     !wb_tryget(wb)))
-				wb = NULL;
-			css_put(blkcg_css);
-		}
-		rcu_read_unlock();
+		wb = wb_get_lookup(bdi, memcg_css);
 	} while (!wb && !cgwb_create(bdi, memcg_css, gfp));
 
 	return wb;
-- 
2.17.1


