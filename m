Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEC18C28D1D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 986532089E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bQT4WuDl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 986532089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 770086B0270; Thu,  6 Jun 2019 08:04:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 723636B0272; Thu,  6 Jun 2019 08:04:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54CE66B0273; Thu,  6 Jun 2019 08:04:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC9016B0270
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 08:04:30 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id l10so471034ljj.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 05:04:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=XWWrktLRhmH5onjl7ijfGHY6CQGMEsILV3xHR3Mmnn8=;
        b=r1ZFiScx/7v2qyMP+rbsjFnEYDvNhnK9UpU46UW3v4br5FreTaTe1m+RK9cb8y/Nmj
         1ul+HDoPiOC+iwCj/n7oEoUvJQVlqycMzVK3K+slvyyxhdfjW3ky6Axpa57aMOf4pJpD
         pH8jxBZq8UtzhoIZ0g8Z11FPRW3QZDBgCLhtQ9J8DcqQ6x/GgG8vTAwP1dloDB7uA9qG
         bzTgwXH8RD2YQw7Yqn0eJWxWQfVOCcXAJ7im8q3Bh9ssEzLUtlarJIybGYfsWTUDj3FS
         dLF7w1+UVV21vExhejdsfV9h9m8wkCfF2kuyLVseEvKZb0jfhDkYcD20SCsUuBP2lImz
         J5OQ==
X-Gm-Message-State: APjAAAUR4ZGUhK0lhTO5g2mYe9ddFnsaAY9ltU+R5kqNFiupIKjCoEX3
	kWLgOQVCnwjxe/P1qDaEspcQSvqy0X5aWXT3UeJn7lQHJemIxKD8Qe+3cLrDE3YPD64fb597Ahq
	GyGbqNbm+Vy12UQGSLOuYl+hxfrdhS34Ak3D7fg518W+9ToJe2Qn9E5ZMa5Ka9hqzoQ==
X-Received: by 2002:a2e:1510:: with SMTP id s16mr15830274ljd.19.1559822670288;
        Thu, 06 Jun 2019 05:04:30 -0700 (PDT)
X-Received: by 2002:a2e:1510:: with SMTP id s16mr15830187ljd.19.1559822668897;
        Thu, 06 Jun 2019 05:04:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559822668; cv=none;
        d=google.com; s=arc-20160816;
        b=ObKOuGsq13cakYgpOyHVk51NXkKLwJwE//rP+it54S6PQA7QOe4aG+e9SgMJXXmngc
         9rM4SkgaylRtEPGRuu4PcFr8NU/XP/aWVJXQF+gxfOCpVhzO50fveGSCrN3w/jiamh6y
         zpJyamYDZvxvVfOCyWh6d8TJoeCl/4UTdoPSUnNaVoDb40slLLQb1884B/A1rz4NszUL
         FhbbKovPXXYqOvU2p9svT+AjPpX/DlVGpXR/MEfS4dacTE5M3D7SkSU5PPeu4EpBbJqj
         EIfNv6truxKv7UoAMr/MscA9a+pmeYo7KjK9v7K/2kaJQ3LOh3Nte1USFrnHo35wiGdJ
         wr/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=XWWrktLRhmH5onjl7ijfGHY6CQGMEsILV3xHR3Mmnn8=;
        b=zd8gtsMjZf6Fmfsujx14Ze6yCWwj0ieqXJypwVKVdpnkQRdmJRT9AKDR58qkcsrl3e
         7/l1ZZXTHxeU944p6AZKduSYa+vHhtj6RaatCcklU9mBhPapP+/0d1pfJd3mBLIfZFmL
         pOAhDLrLcslaD6HrmC/+hDDSO3dpNbfUPqESoOwuEvQ5v1zhBBJKuuFCiQdEYp7iZsoY
         LzVEcFiuCHObVYn6PMzvTPi2UTLOY2+aVh9fFjXJDHEbxagbVx1fMnX5rxLPwyt9GvfH
         Az6iEv/j2uH8Sju22hyLIZDkOFw9gs5j3FtDY2R2pJZtr+x7Xop9Ptx/BUL/7TRzKu9a
         btIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bQT4WuDl;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor483111lfg.41.2019.06.06.05.04.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 05:04:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bQT4WuDl;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=XWWrktLRhmH5onjl7ijfGHY6CQGMEsILV3xHR3Mmnn8=;
        b=bQT4WuDlx82yqPLzBi5aH828d7S/PWpupBCEa50SzGE4GRNiWoaeUegTs9DH/63Db+
         3Aaceh4MKlRNKmnSBRcbq4N5pjyoQjI0cNRy1dlxpn0LT5QTI5rBrfNOYURNJY9SqBct
         C5fdXevDbg8BmUSSzYcbWvuqKqxSCMXcAjmfm7gAoDLiOogur2nPbI0mhUaI8A/PyAJE
         e8g1GhnyMYhcDPjxxzFXahQssbL/mtsQWUtHFzUr3xm01uFdPsjuxXi2PS81JPyeL1ez
         5Ux8SmXB2+DrXu2KWm5NNzyiDOu2tMnVCZgIaZL6GHhIex3BFzixO59045Go+8FTuI0m
         wB2A==
X-Google-Smtp-Source: APXvYqwmXYlkVxNNMJGX5neeMTOxEpgrpeKu/vrN2TjjhK9CMP3mWnApcrZQjx9lDDGfsysi0/QCkg==
X-Received: by 2002:a19:9156:: with SMTP id y22mr9854544lfj.43.1559822668509;
        Thu, 06 Jun 2019 05:04:28 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id l18sm309036lja.94.2019.06.06.05.04.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 05:04:27 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v5 4/4] mm/vmalloc.c: switch to WARN_ON() and move it under unlink_va()
Date: Thu,  6 Jun 2019 14:04:11 +0200
Message-Id: <20190606120411.8298-5-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190606120411.8298-1-urezki@gmail.com>
References: <20190606120411.8298-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Trigger a warning if an object that is about to be freed is detached.
We used to have a BUG_ON(), but even though it is considered as faulty
behaviour that is not a good reason to break a system.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a4bdf5fc3512..899a250e4eb6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -534,20 +534,17 @@ link_va(struct vmap_area *va, struct rb_root *root,
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
+	if (WARN_ON(RB_EMPTY_NODE(&va->rb_node)))
+		return;
 
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
@@ -1162,8 +1159,6 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
 
 static void __free_vmap_area(struct vmap_area *va)
 {
-	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
-
 	/*
 	 * Remove from the busy tree/list.
 	 */
-- 
2.11.0

