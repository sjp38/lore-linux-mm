Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42F74C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F050E216FD
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="O4HjqKHF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F050E216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A12AE6B0279; Mon, 29 Apr 2019 23:09:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C3F16B027B; Mon, 29 Apr 2019 23:09:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88A4E6B027A; Mon, 29 Apr 2019 23:09:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 684416B000E
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:09:55 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n1so12115701qte.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:09:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+np6ZQiGNtF1RzthBJCokkLQhVYLo5zEKFMlgFr5PgA=;
        b=sWJH3aup+d7Av7rDi6TnXZ3pVNjPPj0nzu0vu8VIzPbRFvLt/0HsRnj6KsBj+UsQhM
         N1k+6auaGui3JzU6aqvqIErm9lqE3S8QRgu0FNhhYm9LZrMx2ekVLuiNTtYYxJe1uZkt
         +1WW/W1eeAG9j8jGs0ZGZF22bdD3uEYvfi7KDokB6UKn0Lno5wEo5dhvhTMVtJ0fjC1T
         03rVGwhqg16CianM//tHb2ADW5To7SfCQ8TuRGgSdXax3lp+gfb+ofZwhVD3fWNfETCz
         nXhv2Fif1PGp9JcDfbkaZkeJRI6lvONaEfWm/qL3ChtSrkr9sqCjjdmNqrFhMj/IiBP0
         uDGg==
X-Gm-Message-State: APjAAAXjWyeaRs7Rk1sf+kpBtZW+zW915fklZ8FtJ6JFTmfbnPK4swSF
	2NFScuAwvk07a14pMxMPRbkuiGXoTixkSBTVGkIfxfS+csUHfvm33jcT6MA84WpcMeuyeXD+7wZ
	uPcLrvSCDkfTk4xfulF2y6g7N42K8So/m3wRdzoQnValiqlDZA5OFwMn04bgFRok=
X-Received: by 2002:a05:620a:135b:: with SMTP id c27mr31384747qkl.92.1556593795162;
        Mon, 29 Apr 2019 20:09:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYb9QrfoSC9hRoCdXs9iTAgfTtnqqLoUK1zMMMeIF7p1O419ZLnY+Y21zsZrxXVnCroZTC
X-Received: by 2002:a05:620a:135b:: with SMTP id c27mr31384704qkl.92.1556593794095;
        Mon, 29 Apr 2019 20:09:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593794; cv=none;
        d=google.com; s=arc-20160816;
        b=t2p9AP0UOcltJI8C4k3bsx4c+vmeSRgqSkhqmt7iWqw+CHoFJdUw/AJ81mM8PzyB+8
         E/4knbhfq+0UXkkub3glrY3erlfjstNG9VUY40B3YBvgigDnRG+HBOn811rmfLQC9cYw
         eHxZZ8jczZLcI45ch9TEpL94RTMXyR+hsv0LJo0ZKK+ZpZq3U6FCtZ1G+Xazd1Of0BQz
         MODqal9JMoHSWnekWx6jvOuHh8mCJ/+rcA1wCEsrz9iAygcBfaDJnDTNhTaYgG71BY+G
         AJZk/Le4vQTNNjFIw1HiPbANAxYdhqfpqGmzLRMvpOeqElbK3RijNvIm0IhvjqRn1C9A
         Lw1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+np6ZQiGNtF1RzthBJCokkLQhVYLo5zEKFMlgFr5PgA=;
        b=XciiySl1O0e913N668bpJGawoJpxXnWx+nBrCPhEGLzhoRU1B61vvc9jD1Qv08OIhM
         e5odOl8RDEmW2gKLaOxisPYv+t3NMFeZkPVYpTHw20Q8TuGhg5waqUEXm/xsiPcjPaE8
         BsmQ8RithD+qYaomzJHAWW9w2Ua3JQ9DbY928DaZefnLkSYfOhjBSUafeq6FxfZSqB5/
         HWwl2m3/kS5lUMWhcLeqL6Y14vMww+Kkwb2Z2BDq+hPNTZe1/scsEdzwWjDvQ+4RmFSB
         eFOcvM01Os6LBX/tIPz0t6x3s9SM3vht4NcnDUIzjzqFPobAkuUOTp5RzYyxA842XBeM
         3T+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=O4HjqKHF;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id 47si1144761qtn.4.2019.04.29.20.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:09:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=O4HjqKHF;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id C2BE713DC3;
	Mon, 29 Apr 2019 23:09:53 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:09:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=+np6ZQiGNtF1RzthBJCokkLQhVYLo5zEKFMlgFr5PgA=; b=O4HjqKHF
	BMRO+50OXaEG3RE7O+zTcbPMuVoq49Tf/5PF9HsXBPI5e79VDS2G7Btpm7streiL
	mPYGpSb5EqoTGXMbit0ASRHdTO/VuEdFnkGXxKQJvpP9FdpAX9qc3uQieAXr4LC+
	EviJ7DdeG/qj2woFW13fjvIrWGhgpkRH1fFGlOn522Ie9ktUS2M63bbpixQkBlrr
	A6P8SddlC74ucI3tn1Vowqk8H9ltLaS5a5voileP8jc2CKMakD3pnO2QRMpoZHDJ
	HOWtOLCIYUkb7I5yLLZs0KwfoXKe8YhWXrRDTRMBkS2ormWiEgNN1BaO1TNEM7fd
	WlL7efT8rA9huQ==
X-ME-Sender: <xms:gbzHXBRYTCS4lSNpktxPk71DArwRS-BnzpPHOsmL02zp1DYqxL_5Ug>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeek
X-ME-Proxy: <xmx:gbzHXMbXIto-RNKcWg1auuy9gBGUheu-bDY8jHYo6NsdDaVV5jSQ0w>
    <xmx:gbzHXFhtK3HpOtASk52KwzAUjgLe_FSgvUgUc4tuSekJKYgV0lhONQ>
    <xmx:gbzHXBj20Qh3nUwKUOdfIynKyTWC4N63JRLnJ7MSShy5KXbdjfkBbA>
    <xmx:gbzHXJNtzZFlRT0acLoWbsXmWhL7SErBF6lvdbLaI2-8eWCMy7tmlA>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 118F3103CB;
	Mon, 29 Apr 2019 23:09:45 -0400 (EDT)
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
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 09/15] xarray: Implement migration function for objects
Date: Tue, 30 Apr 2019 13:07:40 +1000
Message-Id: <20190430030746.26102-10-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190430030746.26102-1-tobin@kernel.org>
References: <20190430030746.26102-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Implement functions to migrate objects. This is based on initial code by
Matthew Wilcox and was modified to work with slab object migration.

This patch can not be merged until all radix tree & IDR users are
converted to the XArray because xa_nodes and radix tree nodes share the
same slab cache (thanks Matthew).

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 lib/radix-tree.c | 13 +++++++++++++
 lib/xarray.c     | 49 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

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
index 6be3acbb861f..731dd3d8ddb8 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1971,6 +1971,55 @@ void xa_destroy(struct xarray *xa)
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
+	if (xa != node->array) {
+		node = new_node;
+		goto unlock;
+	}
+
+	memcpy(new_node, node, sizeof(struct xa_node));
+
+	if (list_empty(&node->private_list))
+		INIT_LIST_HEAD(&new_node->private_list);
+	else
+		list_replace(&node->private_list, &new_node->private_list);
+
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

