Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A70FBC0650F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 18:46:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E04A2054F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 18:46:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OS4OCsP8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E04A2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BE4B6B0006; Sun, 11 Aug 2019 14:46:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86F9D6B0008; Sun, 11 Aug 2019 14:46:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70FF96B000A; Sun, 11 Aug 2019 14:46:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id 50EBD6B0006
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 14:46:30 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id F16FA2DFE
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 18:46:29 +0000 (UTC)
X-FDA: 75811027698.27.shelf71_1b97375d72862
X-HE-Tag: shelf71_1b97375d72862
X-Filterd-Recvd-Size: 5216
Received: from mail-lj1-f193.google.com (mail-lj1-f193.google.com [209.85.208.193])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 18:46:29 +0000 (UTC)
Received: by mail-lj1-f193.google.com with SMTP id k18so96414384ljc.11
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 11:46:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=sHzzzA2xQ402RWvU0Hu0IKz3pQGvFb+F2/QvqTcdhf8=;
        b=OS4OCsP8BenhY51p8Ak6rLYx4nCshsn6TVflf7rjLCbw1BgGGoFNcGyLh2d1XIwIv3
         CqpNm2hBHMWtealt8suXi5VqYKlCHgoBK3yIWBcTQ6d1Bxx9+U/B8WITXCMCVwauWKgv
         M1jUOKF46HqhGVZuPcW+n5HesWClcxctftF/m4cU+uusN1I5uyeOPgH/l2Bvea0mbZmb
         xZwTCqBcTbL5PwVPiSZksFX56bxzIg02REWywzbZWohvsfAs1N2/yAYi0HbTEjVtH2Zu
         IU/cJK3SEA2GPlbZa0WPk3svaJ+z6tVRWVjuktLxxIeB5fOaBkj+Np+rll68+9+uxmyn
         xKSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=sHzzzA2xQ402RWvU0Hu0IKz3pQGvFb+F2/QvqTcdhf8=;
        b=NJ2Dgr5JskYHbomUeS/1W8YFjHrhxyENiCl0qO0gAKw6S18MDMbE0k8ykU+PLSPWlX
         fF4owLLLviiumnoG+I+I5IGZ6RVSxW1GqaCYNOAJOkz5urk+yLyY1tb0z1q9oydcVoEu
         of+MwnQ2hUbNiqa2k9DFPtdnIi6oKl1DqDWYvRMX3ezge9S5xeVUFJiCoLw2z4XsoEOY
         GuaQg9KTx7AVu72H5Zv/EGWtDCHhjfqfZhyPo4fAVqTm2BXRCwq/ndQyUdRg3logXhhB
         sVTZRZZe7tLOaC48IdtpgKUDXqf/7Uu8J9F4g+CSHCHR1/EbGjfj6UN4MrOHJQChznuU
         IMjQ==
X-Gm-Message-State: APjAAAXIy+saYk76/KkGlVb+8F5FbuOydVZBsVrDFlEwG2Iqz2XnDuTh
	a5PPaL/fJZ/0Yw50XNUXSA0=
X-Google-Smtp-Source: APXvYqxOFPiSBzpEvwA4o0KKqFwesdC+LHIdPwuhVDpto0/o8yY2Owf8hxw72k10f1rYMVkEyjEzwA==
X-Received: by 2002:a2e:9d8a:: with SMTP id c10mr16554929ljj.147.1565549188182;
        Sun, 11 Aug 2019 11:46:28 -0700 (PDT)
Received: from localhost.localdomain ([37.212.199.11])
        by smtp.gmail.com with ESMTPSA id t66sm1536425lje.66.2019.08.11.11.46.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Aug 2019 11:46:27 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 2/2] mm/vmalloc: use generated callback to populate subtree_max_size
Date: Sun, 11 Aug 2019 20:46:13 +0200
Message-Id: <20190811184613.20463-3-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190811184613.20463-1-urezki@gmail.com>
References: <20190811184613.20463-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RB_DECLARE_CALLBACKS_MAX defines its own callback to update the
augmented subtree information after a node is modified. It makes
sense to use it instead of our own propagate implementation.

Apart of that, in case of using generated callback we can eliminate
compute_subtree_max_size() function and get rid of duplication.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 31 +------------------------------
 1 file changed, 1 insertion(+), 30 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b8101030f79e..e03444598ae1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -385,17 +385,6 @@ get_subtree_max_size(struct rb_node *node)
 	return va ? va->subtree_max_size : 0;
 }
 
-/*
- * Gets called when remove the node and rotate.
- */
-static __always_inline unsigned long
-compute_subtree_max_size(struct vmap_area *va)
-{
-	return max3(va_size(va),
-		get_subtree_max_size(va->rb_node.rb_left),
-		get_subtree_max_size(va->rb_node.rb_right));
-}
-
 RB_DECLARE_CALLBACKS_MAX(static, free_vmap_area_rb_augment_cb,
 	struct vmap_area, rb_node, unsigned long, subtree_max_size, va_size)
 
@@ -623,25 +612,7 @@ augment_tree_propagate_check(struct rb_node *n)
 static __always_inline void
 augment_tree_propagate_from(struct vmap_area *va)
 {
-	struct rb_node *node = &va->rb_node;
-	unsigned long new_va_sub_max_size;
-
-	while (node) {
-		va = rb_entry(node, struct vmap_area, rb_node);
-		new_va_sub_max_size = compute_subtree_max_size(va);
-
-		/*
-		 * If the newly calculated maximum available size of the
-		 * subtree is equal to the current one, then it means that
-		 * the tree is propagated correctly. So we have to stop at
-		 * this point to save cycles.
-		 */
-		if (va->subtree_max_size == new_va_sub_max_size)
-			break;
-
-		va->subtree_max_size = new_va_sub_max_size;
-		node = rb_parent(&va->rb_node);
-	}
+	free_vmap_area_rb_augment_cb_propagate(&va->rb_node, NULL);
 
 #if DEBUG_AUGMENT_PROPAGATE_CHECK
 	augment_tree_propagate_check(free_vmap_area_root.rb_node);
-- 
2.11.0


