Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B920C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:39:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2D5B21743
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:39:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WdyDohT7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2D5B21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 113F06B026D; Mon, 27 May 2019 05:38:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09CDF6B026F; Mon, 27 May 2019 05:38:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E59096B0270; Mon, 27 May 2019 05:38:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 769B66B026D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:38:58 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id q20so3085580ljg.0
        for <linux-mm@kvack.org>; Mon, 27 May 2019 02:38:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=5tFxW9hH4KTKWLbD5PL7NocPZCk93KxY6ol7ln5ws1s=;
        b=NeheIFffpUsh4sNpadK7rR0dZpy92rnEwsWq4FTBY0eTJbQlTdcgPBtYZog9OCgjpN
         6uGeWQOyebmtUyM3OuZJqtv4spq9ahr9JfXIQV/fYBSk9JcWPr039iGALLk+/MefgZzb
         iRLyy4ACLIve9UuiNGDw1P2eMjMbUccv/MNg714SzYK2UFrqpF7DsF4X9YbUzJMNiSEu
         mqLAt9I43+k5E2b/7P1J8uwxfovH2WhqVPdRc56zuBKDNaB9lNwjzxh6zxMGdY/dV6M3
         W/8bSkV1u8GtxYnqwrv+xFMjGtBThjlfkykhma/fEAbbKHWGPtso8IDcvell7thY/yLm
         rEqA==
X-Gm-Message-State: APjAAAXojJzm1DrpWYjPCnIikGCDKQL3USo9E2CjLIaAqsQiv67lcg/m
	JswfM1dru566W186Mv5YeN9mEIAbdVBShqHTrkgh4UmOXa6/HX255qFNFyvHdAZGCHQCtba51oD
	nDssXWtEQLu1AEo4frxlHzLW6JT+LSIu1L3GCbg2XTOmgtFYV9vLFR7AlVgN8HOOd8Q==
X-Received: by 2002:a2e:9185:: with SMTP id f5mr30990585ljg.51.1558949937879;
        Mon, 27 May 2019 02:38:57 -0700 (PDT)
X-Received: by 2002:a2e:9185:: with SMTP id f5mr30990540ljg.51.1558949936822;
        Mon, 27 May 2019 02:38:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558949936; cv=none;
        d=google.com; s=arc-20160816;
        b=mTIpEFBb0FxQhHUdiKEU+BFJFTfun12KenLed/D9SuaoaZm0lc6TFSiwIV4/mN+KHy
         wIaalfs7LSwzAmp0iJR/pkfhrGATtueInNs3V2ZpYsYTBRRNDVH3xrd4jqPiXUf24baT
         vjlqkBANhehQMnokMhpc0R28iTzSlsShddUfq0SxXQR1Lmz17ECnXbpaEaNId+r7x5UI
         Ykbs2e4zjSZ9IH4TrGOdlGgbSS54EI7dFRsEuhFALo+fqE03YB2KLDoydrkKmP2A4lvH
         RAKB6ol5qcNTJTU7iLyIbWlUMHooZ9d579AWaftIsbpmk+xgbqZ/AoXJ4azKG6UpZcfh
         usRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=5tFxW9hH4KTKWLbD5PL7NocPZCk93KxY6ol7ln5ws1s=;
        b=l2LFtx5oZttRlRshdMOvmmL+WnkVIsBE77EYqaDvZ5gXyvy45hkGbfZ/YK4JLjcRyF
         /z4unNX8Fjmfm63zQ3DGLsjC55htkJQaWVmum/WMITkheCsQqUBbx94ylofJqiCHzBkd
         zmIh0c8jlq8QMBCo8/XGREQf5hvXvQxqDqm8rl5LDjAh2PeEO35t3HJMjJ8tz5GxMSKS
         TPIcIAKGHUa8bfgJx/mzRcuvgUmRgIGwyxhpjofeJ22zNpL+B/Y1WfKeQ1ZHbQXRGmBJ
         8+j+yOeoU0NFFi8VxWmzGzrQCkjfDvG3krDuPdYKqwVndbBEAIGlqsAc/PMZBs6G4YU5
         Etpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WdyDohT7;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor2555270lfn.7.2019.05.27.02.38.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 02:38:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WdyDohT7;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=5tFxW9hH4KTKWLbD5PL7NocPZCk93KxY6ol7ln5ws1s=;
        b=WdyDohT79RWv5sQw8j/CoiyAF1ieXhBzh55F/UbajT9jF/0uJ67nJC3KNnHTUPoI0T
         oUBP1DChU3kD4+oixvGJZjalRgEuupfxfw3tAciwmhJ8azlHnw/9zdY211g0HetUZqHo
         pcLoUQjOziPwn7lefVncMQD2ZdI0BPz9lVodeDp4CHJnFXoNRL5DLmsx9CbYtKPcw5No
         UCR/uvKE8YK6JKhvoExYF/ggb0izBa8VIDKiBvqNTs5o+yZ8G4Hrb4BkQtKx1Z4I6Pvb
         0wCCaGD8KZvWTFTFFm9Z0/PQLWWVEWN+7T6Eg+/RaX3QawT2c0YbBBzBtdNCU4JatZ7j
         wZ9A==
X-Google-Smtp-Source: APXvYqywlNbALD5TT5l11okB4ZaZ9LJNYUAYl35+RlPAv4hvj0NbaW0wQ0+uLocyyjJWapoGw3TE1w==
X-Received: by 2002:ac2:5324:: with SMTP id f4mr5086344lfh.156.1558949936459;
        Mon, 27 May 2019 02:38:56 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z26sm2176293lfg.31.2019.05.27.02.38.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 02:38:55 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Date: Mon, 27 May 2019 11:38:42 +0200
Message-Id: <20190527093842.10701-5-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190527093842.10701-1-urezki@gmail.com>
References: <20190527093842.10701-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
function, it means if an empty node gets freed it is a BUG
thus is considered as faulty behaviour.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 371aba9a4bf1..340959b81228 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -533,20 +533,16 @@ link_va(struct vmap_area *va, struct rb_root *root,
 static __always_inline void
 unlink_va(struct vmap_area *va, struct rb_root *root)
 {
-	/*
-	 * During merging a VA node can be empty, therefore
-	 * not linked with the tree nor list. Just check it.
-	 */
-	if (!RB_EMPTY_NODE(&va->rb_node)) {
-		if (root == &free_vmap_area_root)
-			rb_erase_augmented(&va->rb_node,
-				root, &free_vmap_area_rb_augment_cb);
-		else
-			rb_erase(&va->rb_node, root);
+	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
 
-		list_del(&va->list);
-		RB_CLEAR_NODE(&va->rb_node);
-	}
+	if (root == &free_vmap_area_root)
+		rb_erase_augmented(&va->rb_node,
+			root, &free_vmap_area_rb_augment_cb);
+	else
+		rb_erase(&va->rb_node, root);
+
+	list_del(&va->list);
+	RB_CLEAR_NODE(&va->rb_node);
 }
 
 #if DEBUG_AUGMENT_PROPAGATE_CHECK
@@ -1187,8 +1183,6 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
 
 static void __free_vmap_area(struct vmap_area *va)
 {
-	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
-
 	/*
 	 * Remove from the busy tree/list.
 	 */
-- 
2.11.0

