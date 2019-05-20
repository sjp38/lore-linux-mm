Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BE0DC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6F1D206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="tuExDE8O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6F1D206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88ECC6B0270; Mon, 20 May 2019 01:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83E996B0271; Mon, 20 May 2019 01:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 706D86B0272; Mon, 20 May 2019 01:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E56F6B0270
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:42:53 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 49so13156466qtn.23
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:42:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KJQThgKBrb4Q/HDch0M4apqEnwzOiy7Mz4o6TMTuCfU=;
        b=VSnTAfELAtZjT7DiABm2da+TXil5j6ky8JVxTYWehKvOeOC6P0521aCiMtbMqKuJdD
         Ezo48mmcaemmcd1f/NKRgXEbWhBzG87xTOAmx6Cm74b5KL684fX65n6JBalPav02nY3J
         N5428vcQQzUoNcsMIquCpElcyKG9sdWD9Zz61wbxGJcehF860EtXk0ksJOed8cklNEo1
         6DQsesqTfP03HbDKS+Gq5daM8bZj7m9i6IzvA6W9h4O7E1SG5Vfn4jSgZu2oVlPvdYrX
         B+vThHC4LI7K9/UPPkjjhcDPdfvm35g8JA9cddsZIuCpd3ldIzyf1znX6Q5ahsNJSSt/
         eAug==
X-Gm-Message-State: APjAAAUcLUHpqIx/yXIv4q9UHqhiRcW+nTVaJPI3AEO0dgm32KfZYwUz
	kxlsVBvlUP2UJVf0NQtyKE7YDEm7sjOXQrcpiXDIzR8zOJAzGOXDdjXxDKq2Up33dmoOv20nBVF
	0SqMEw3Q5DTzmj38+kSx55ZJudgvyElga6gtSveOJB5v26X5Nbi5gZRN0imz9238=
X-Received: by 2002:aed:237b:: with SMTP id i56mr43935232qtc.370.1558330973087;
        Sun, 19 May 2019 22:42:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysDVLSmCJLq9f0Hy5N0GN9GFho345ZqULVgwrtM+b3msoVq9GG8f4iJNZm/x3w6SK2+HxO
X-Received: by 2002:aed:237b:: with SMTP id i56mr43935192qtc.370.1558330972168;
        Sun, 19 May 2019 22:42:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330972; cv=none;
        d=google.com; s=arc-20160816;
        b=AVYrbbMJcb7a+GIW2hhw6NNVs7bPjW639XvZ15A41SNPa7cGH+r+DapB4amuhDDCNS
         xan4+DtQDBnuFyQS+tkwK6BnoMGrUI703MZvRTnGIEIyZiGrbiU1umR6QCJxpLUq9MVE
         Ac0/0p1ifTTTnLjoqf+tUQGQjWJrVyk0Lp7XO/uTgxysQFcEIojibidicy+x4DmEX2MO
         lWrsMV6CoysAEt9rIJ3QE+P8ZYxfRAhXaqNcv/HYFEW3zQarsA4FOKnl9A4cMPZskv3V
         t9rKZSofMGaH0ZeCC/ns5u55EihPaj+jr/TuhppzFiOwEf8BpA6KSNMQHTj3RBf6kGc7
         kVrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KJQThgKBrb4Q/HDch0M4apqEnwzOiy7Mz4o6TMTuCfU=;
        b=kZDQI/SRcAWfb+k1c6/bRHDz94WG6cjKKC8mv25pzLq2oU0cdX7XhGmTwxgc/A2JIH
         ztVsb/x0zIU4vO+EStxVfo+eKp/Yu0AKlSHdP22KcPdXa8YK0TwssGH/FE0RkeF3W5Yb
         7/oOPBb1PhspB+hFjKvT6Yb0v9Bw0nGDGTe+U7a4wcRYG5pMCYlNF9tjt9HOOS1RwztX
         G3vtnUu/toqDyAwm/HiGMACswOB8brHXSzvWfFFYgE68RVAg+geAAoUpQtftGSNrP7C3
         Ig/o3JojRr+cTWN+Uv9fU8FbckcMCweZ7QNuEr/pGMJYtpttL47TyQ4U2P5HLdLFw5EG
         aveA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=tuExDE8O;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id t8si772318qti.213.2019.05.19.22.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:42:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=tuExDE8O;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id DDC63101E4;
	Mon, 20 May 2019 01:42:51 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:42:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=KJQThgKBrb4Q/HDch0M4apqEnwzOiy7Mz4o6TMTuCfU=; b=tuExDE8O
	RkcZizOzolt761iWo9hMoZ8sDm2tcPebJBTnsY0OaLLfnyYN8biO1EdE51FuM1gb
	3d2kD7w8qkpPqccJPkgo9sGipp7cWUnj6W2qCKQGBlVDEbaw9uyo+s5PPWM0oepo
	t+HHcUTiGINV34TQ15eeY5TWwCZHyK8axgikJjiquVb41leTKv3fh/dxzOCYqj6o
	rXjo0BvFTNd85SqshQplNuCxEi9O/dx7aT6o5U9bdU3GZVjR14SlDDAo25xfhV3l
	7jAd+Po++qBSx1L7tYMq8pEMLjvXqg6JTX3bV56OLYDMShyfbQTMtlfSBCdkX0RO
	3XiVa+os9y8niA==
X-ME-Sender: <xms:Wz7iXO_eIYq7T09EukrAFkJfsUIh0CDqC-wd0N6leecX9zIQp7pp8g>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepudef
X-ME-Proxy: <xmx:Wz7iXMizKt4vn9bjRYQa2CLv8_iZwpnSzHOuENV7lRXIMTWmCx2_sA>
    <xmx:Wz7iXOdxVc-qCOV2CtnFwbkh3gcn1KNDJXOdvlp9VRvTcYtBFzjYMQ>
    <xmx:Wz7iXDpXQa1BSGGfxHb6pXwZeARvPoMewNKJ532t_eet9lMOhHP1iQ>
    <xmx:Wz7iXJRGEzCQCE3wuCLOcHoLT24NsbhhUtna0kHLB_L58zlDhO6kUA>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id C22CE8005B;
	Mon, 20 May 2019 01:42:44 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 14/16] dcache: Provide a dentry constructor
Date: Mon, 20 May 2019 15:40:15 +1000
Message-Id: <20190520054017.32299-15-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190520054017.32299-1-tobin@kernel.org>
References: <20190520054017.32299-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to support object migration on the dentry cache we need to have
a determined object state at all times. Without a constructor the object
would have a random state after allocation.

Provide a dentry constructor.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 30 +++++++++++++++++++++---------
 1 file changed, 21 insertions(+), 9 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 8136bda27a1f..b7318615979d 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1602,6 +1602,16 @@ void d_invalidate(struct dentry *dentry)
 }
 EXPORT_SYMBOL(d_invalidate);
 
+static void dcache_ctor(void *p)
+{
+	struct dentry *dentry = p;
+
+	/* Mimic lockref_mark_dead() */
+	dentry->d_lockref.count = -128;
+
+	spin_lock_init(&dentry->d_lock);
+}
+
 /**
  * __d_alloc	-	allocate a dcache entry
  * @sb: filesystem it will belong to
@@ -1657,7 +1667,6 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 
 	dentry->d_lockref.count = 1;
 	dentry->d_flags = 0;
-	spin_lock_init(&dentry->d_lock);
 	seqcount_init(&dentry->d_seq);
 	dentry->d_inode = NULL;
 	dentry->d_parent = dentry;
@@ -3095,14 +3104,17 @@ static void __init dcache_init_early(void)
 
 static void __init dcache_init(void)
 {
-	/*
-	 * A constructor could be added for stable state like the lists,
-	 * but it is probably not worth it because of the cache nature
-	 * of the dcache.
-	 */
-	dentry_cache = KMEM_CACHE_USERCOPY(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
-		d_iname);
+	slab_flags_t flags =
+		SLAB_RECLAIM_ACCOUNT | SLAB_PANIC | SLAB_MEM_SPREAD | SLAB_ACCOUNT;
+
+	dentry_cache =
+		kmem_cache_create_usercopy("dentry",
+					   sizeof(struct dentry),
+					   __alignof__(struct dentry),
+					   flags,
+					   offsetof(struct dentry, d_iname),
+					   sizeof_field(struct dentry, d_iname),
+					   dcache_ctor);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
-- 
2.21.0

