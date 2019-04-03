Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13456C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B10EE2084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xeXsXdNf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B10EE2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 644CB6B026D; Wed,  3 Apr 2019 00:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F5AF6B027A; Wed,  3 Apr 2019 00:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BDF56B027B; Wed,  3 Apr 2019 00:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDBA6B026D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:23:54 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 23so13538792qkl.16
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:23:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uAywuLhgM6+Szq4etbWPzwmP073FVonmktwU8/xEONg=;
        b=aMhMlIJGbF4QJ3XeSWpI7RPRl8AHO0cvNuM1KebXT12u66abNyLf4X+6f44L3RJKjY
         B6Y/iFYvvd2mpFvoGfCgHrmuSSOLye97Z4hB69a42Fyd3mOU0Ve3qpFqpCnQoTsiqruE
         +wCoEXCkYfKpgWOORAIVcHknaEtEb7UfrSsCkFPEO/iE1B9SVr96aC28lM7fCprVYSdS
         DUzaF+z6eIPP425snBsu0MwK0wBCjT9XyXjWpVL+AfqLvCj4a+yJzWHd9lMeAweOZkC3
         9YXseuwVnueXXnq4KU1eOD2VMlhPVQA/ogAgeVM1PxDsZmjlAc+u8xAJB43dNmRqiUZx
         GAdA==
X-Gm-Message-State: APjAAAVRTXkqs+lagCrEIGRhtBg1ii9P99OqisgeUsawlVoSFyByCL/n
	Qv0QGHLMwK29EtD5PeqeZQmyrZy4lRf5kfL2T3+2a6YNZmWWdnpznsfs8aid9VzHFHsgpLDyvbi
	ApAzMGQFoZEqAeXxW61F3fuFFIqw7L8o+dxln97JAlohx4MT2FDo85QDED+L+YSM=
X-Received: by 2002:a05:620a:132b:: with SMTP id p11mr93947qkj.279.1554265433938;
        Tue, 02 Apr 2019 21:23:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQn4UMtrPQ0Om/0T/QiDecaolJ1rWFJ39GPw76cJ4OEF0UfbvVKjZv7BJSiyFxkTPSSeV3
X-Received: by 2002:a05:620a:132b:: with SMTP id p11mr93899qkj.279.1554265432875;
        Tue, 02 Apr 2019 21:23:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265432; cv=none;
        d=google.com; s=arc-20160816;
        b=uIkEHvvb4mmgTiQnSPBDFSBqOUAk3WuhhbX10BGkZa8dbK/7Mcui9/rjJrlh8Orx2v
         FPAtHOYLi/QBanr0TciMFGGWQaS+q/UxCnvXsq/Czv6FQS6qhF00IYMAdU3M/50OiEWX
         IO15I67pmI9gOPCbiRqV2Yq1Hby49h0SABmFhAHqg7emUWCkp8h93i1Kt/pCX+Ax+EHI
         MSEXUpls+R74yesvHJPmBYyA37tIY7TiLuoC0ifM/p80wDzo+WdamLulaJZh8U4GEAqg
         VC3mMYq/2nMmupyHwI8xnVWU2eSjjeYaRYVLJES3lXwU8DYv/RP8tuHq2vE7omV6lSi6
         bmKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uAywuLhgM6+Szq4etbWPzwmP073FVonmktwU8/xEONg=;
        b=F8cvRrBapqE55PJ9lcscjaJF7QzMvEHINwvQRYsBzO84LG9HueZ+tAFohxOWtuEybh
         YB96EPNzb7LkppAN1eX3Tsqk2/lbrCHu1gu1AOl66wJSxyoQKL5CRRHCSILnAXSo+yiB
         risdMt0f6AB9Zgapy3+Py/onXopMPxxB92CFoO2CdZAU6vY7/cQrcqgrdpe7PYWGrNyB
         RahXJEthxWDp7zgAciP+5sDxog6zO2e68uOvsfMNqYYv/9uh7zEp+AtN3OUtLJu6Q3Ax
         AE/g4G9n13ltN9b/aZjG97tn/+KdhxAMrLztDs3VgCU1AzAeEkXqoH0UuoWPG5MlavXz
         8NzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xeXsXdNf;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id n64si2500264qte.106.2019.04.02.21.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:23:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xeXsXdNf;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 91FB421B84;
	Wed,  3 Apr 2019 00:23:52 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:23:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=uAywuLhgM6+Szq4etbWPzwmP073FVonmktwU8/xEONg=; b=xeXsXdNf
	P0XevguDVWe8R0wWT3qYLmuo5crZKYPd4pltu4WJxBU0f1oEsa362LSpgZ4CdNQZ
	InDlUyX3uK85y8/EYAAhVz5TMUtIHMgU5XXYa5LIjJPFILKnrfjMeJrdXL/dSU6Y
	pJlOZ3Mo836ihiKeOtTmLe+/CGXJQ8tmDK3FsS8LQUztBoDAC5+NA+JnSY/Zs4F4
	o+IXwNfDR69U8p86UcIwY8UpCknhFqteRa5q7IUTo/MbwI//s1f3+TKLxZTEVbA8
	HKFIpylGzC69vJxjlgNyf1x9aio4JulIFvN5CtZCFtfVq2Sk50jrULAcxMsV3Mx1
	hz3eqk7G3QXNhg==
X-ME-Sender: <xms:WDWkXD92euADIF6N_DJbNWkSRO_N_CpcPFa1Sim91M773aIhopolVg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeek
X-ME-Proxy: <xmx:WDWkXClVAC0W5egos2v__G-wTzSARXKpUdBkMXnkSCfzSuzyzdSc3w>
    <xmx:WDWkXB245maRTv74OLD3kfyMI-v7-lhMbnlQL7b_QghGi1syx0TTqw>
    <xmx:WDWkXBRIHyxbCeDYWFfWcDfhHfVNqUKTfCX5zkvnPZIBIPLL0CJIyw>
    <xmx:WDWkXCJTa2wZTEzm6tGVMXngzOJXHP0PrA6YFc9lOtPc90Dn4cowdQ>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9597A100E5;
	Wed,  3 Apr 2019 00:23:45 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v2 09/14] xarray: Implement migration function for objects
Date: Wed,  3 Apr 2019 15:21:22 +1100
Message-Id: <20190403042127.18755-10-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190403042127.18755-1-tobin@kernel.org>
References: <20190403042127.18755-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Implement functions to migrate objects. This is based on
initial code by Matthew Wilcox and was modified to work with
slab object migration.

Cc: Matthew Wilcox <willy@infradead.org>
Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 lib/radix-tree.c | 13 +++++++++++++
 lib/xarray.c     | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 14d51548bea6..9412c2853726 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1613,6 +1613,17 @@ static int radix_tree_cpu_dead(unsigned int cpu)
 	return 0;
 }
 
+extern void xa_object_migrate(void *tree_node, int numa_node);
+
+static void radix_tree_migrate(struct kmem_cache *s, void **objects, int nr,
+			       int node, void *private)
+{
+	int i;
+
+	for (i = 0; i < nr; i++)
+		xa_object_migrate(objects[i], node);
+}
+
 void __init radix_tree_init(void)
 {
 	int ret;
@@ -1627,4 +1638,6 @@ void __init radix_tree_init(void)
 	ret = cpuhp_setup_state_nocalls(CPUHP_RADIX_DEAD, "lib/radix:dead",
 					NULL, radix_tree_cpu_dead);
 	WARN_ON(ret < 0);
+	kmem_cache_setup_mobility(radix_tree_node_cachep, NULL,
+				  radix_tree_migrate);
 }
diff --git a/lib/xarray.c b/lib/xarray.c
index 6be3acbb861f..6d2657f2e4cb 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1971,6 +1971,52 @@ void xa_destroy(struct xarray *xa)
 }
 EXPORT_SYMBOL(xa_destroy);
 
+void xa_object_migrate(struct xa_node *node, int numa_node)
+{
+	struct xarray *xa = READ_ONCE(node->array);
+	void __rcu **slot;
+	struct xa_node *new_node;
+	int i;
+
+	/* Freed or not yet in tree then skip */
+	if (!xa || xa == XA_RCU_FREE)
+		return;
+
+	new_node = kmem_cache_alloc_node(radix_tree_node_cachep,
+					 GFP_KERNEL, numa_node);
+	if (!new_node)
+		return;
+
+	xa_lock_irq(xa);
+
+	/* Check again..... */
+	if (xa != node->array || !list_empty(&node->private_list)) {
+		node = new_node;
+		goto unlock;
+	}
+
+	memcpy(new_node, node, sizeof(struct xa_node));
+
+	/* Move pointers to new node */
+	INIT_LIST_HEAD(&new_node->private_list);
+	for (i = 0; i < XA_CHUNK_SIZE; i++) {
+		void *x = xa_entry_locked(xa, new_node, i);
+
+		if (xa_is_node(x))
+			rcu_assign_pointer(xa_to_node(x)->parent, new_node);
+	}
+	if (!new_node->parent)
+		slot = &xa->xa_head;
+	else
+		slot = &xa_parent_locked(xa, new_node)->slots[new_node->offset];
+	rcu_assign_pointer(*slot, xa_mk_node(new_node));
+
+unlock:
+	xa_unlock_irq(xa);
+	xa_node_free(node);
+	rcu_barrier();
+}
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
-- 
2.21.0

