Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 898A9C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39C21206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="wY4kIaUF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39C21206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBF0E6B027F; Wed,  3 Apr 2019 00:24:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6F586B0280; Wed,  3 Apr 2019 00:24:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C37CE6B0281; Wed,  3 Apr 2019 00:24:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A40DD6B027F
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:24:31 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so15667806qtz.14
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:24:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3CgZchYLd16ww3/LiD/mAfG7GXA+RJSG10+pHsLIDks=;
        b=nQlYBqot0kpcuzlZ+bjFOkqxaZvoxAJ9ox2kDDoAnxiG6Q9t0rm6r+MUWH7Q9wIwXn
         1MkaRrEmGgWhD/AMWjGFqKWlhtpAPSkrTZMARMfRfYFDR7EN3w2WZzBm4s064SMtCiY8
         eiykS6gE8nXFZwapk71vkqBhJupxt7Gn3Gp8z2hATDduevGCExqdo9xGGFr9NbaAkmzc
         Mnot/9wY3vYlV76uvsfPrni7bMgWteBv4eWIYiHcNX6qwn6sKJdUahgBtSfpj0RxWufG
         LZIRqdR1fyH4T1NFydIQCrO8Ek5l6TBcTXfTxx5mnwL8ot+AqBizMEhjbTZJBQVG83xs
         DO6A==
X-Gm-Message-State: APjAAAXAPq+WBji3MnPM8xIhNhjnbDZzSTj/30gudzuSnbljyI6xbUF4
	od2op63+19fUbPqBM+ODezC4aYK1DepDJZQRUaJb2vNUeHxKYCkJZnsqyI0GNPE8UuLAb4OYwzy
	+6+AJLbyyUlVjAGofqlfr0rWsvbo7nn0QmX9T1ADGkSEZLNGeHMyx+HV3goiKTfs=
X-Received: by 2002:a0c:81e2:: with SMTP id 31mr25271444qve.179.1554265471416;
        Tue, 02 Apr 2019 21:24:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzykPWLxF7/qOPnYO5FBUcMWiT5GC2F7KFuQj+bc6b4N8oW8GZ4o1ny0QC8Ld/iuJYCD0sJ
X-Received: by 2002:a0c:81e2:: with SMTP id 31mr25271396qve.179.1554265470185;
        Tue, 02 Apr 2019 21:24:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265470; cv=none;
        d=google.com; s=arc-20160816;
        b=OxPgaQoCvijFjP+XskRWfcQRqaxbWCUCywlMJOezJLvVKizxuDWnzh17bySO0hqk+J
         S7cLk+8PCYqLLmfLuuL/HVjoDfsLCSirwgOJEWNNSMP8PjfXrfqJDDQRrAAU2d7bPYoW
         aqM7q9NiX494alKUlpPU7xniuGs862lenljHOUanhV99yNNeLc9v3hlHD8k41QjOM41/
         g+UEvX5vNGtlY5wOPs/oWPjhhPIeGRp6Nb4wd1OiT3kWW2/uB1Vx8XHj88J6M3r2P8JR
         JFQYK1lqbeSLTJZ9TOsXnvL74cGdK4/O20o6junIhxpFQgQAewnXD8HZDfEzQg42Ejum
         0/cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3CgZchYLd16ww3/LiD/mAfG7GXA+RJSG10+pHsLIDks=;
        b=dCiJAFjrzm7ii1fvcBX0mZuyB6jyXqDy+ee8xgnsh0Q/3M2AUqr29+RGbVjiIMKcJz
         Aw/85Y+DAxecHOMKtLGBvdJcUuV1iGJZ9I6+jMrRQuTZLJ/+Dpc0JsK08I/DoJDjbdbC
         4Oh4QlNY9EMcONJ8VWktqAz4cgYI/Op5zI6Iz9eN03y2+BJkwqpcefeworH8I2bd6zbP
         soPVppYNBhamyTjU7MXbK06vk7xj8Ja7K0C0XRRQ/y0uteXXh0lRKnY433ZJrZcznKrE
         uFdhHcGMVDMWtfpQRbn5ZVwrU+kIFCm/vzxVD8zRb/Tb3Fd8s+ejQgsRZ43apS1FJ6Dt
         tAOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wY4kIaUF;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id n24si1690641qkk.23.2019.04.02.21.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:24:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wY4kIaUF;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id E23B621FAE;
	Wed,  3 Apr 2019 00:24:29 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:24:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=3CgZchYLd16ww3/LiD/mAfG7GXA+RJSG10+pHsLIDks=; b=wY4kIaUF
	bKeyoZ1pX1nCWrBGHGHId2HQJ7fpODFRyw9W9hbVgEBM2F+znekZY9/Ya6bpkQLx
	g4bxXkC0jILJxfUFw+Xp/nP9yTQgozkM4b4uJR7dSeJn7Du55PXTCh12806jtLbw
	ZZtzaSMa5mrjyPZji51A8vd+/ku4ZVL5Qd4QTYWu6LVgY3XDelhAATeQIwGLJEeb
	QLOnXlctXLmYy9UVB2VQXXHy3Vce14hsYi8KLRqRXNOdpfUzNHOb/opiGiwyMH4x
	NkPSYl8X0PHNA6n6iOzmg96i85YHVOD3FW9jf9WsUSTJx9TKvaAriKhZyw0pb5db
	fRyyTYkfF5tEDg==
X-ME-Sender: <xms:fTWkXJ1HmSTc0NWQ09l2pitFB5VEPfcu0zy0mThfRuP5raBiya01rw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedufe
X-ME-Proxy: <xmx:fTWkXEWBexcOAxb392Gqp6hyOG49Ztf-_U-rHA-Ki1tgG_EXiz3SFw>
    <xmx:fTWkXE71ALl-nmH_kBAHCYj0V9luUF7MdvkNuNAvN2vb3BaTTEJHgA>
    <xmx:fTWkXLKPs3hYiX2DVAR1NpMEGBeVt946yGWKOEB5mD5Fa_gWKvPFRA>
    <xmx:fTWkXOk_bHrx8S3koLe_9eTZGaPPkor3nTsEOKI-tg__FRSGz1lR4w>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 0A2BB10319;
	Wed,  3 Apr 2019 00:24:22 -0400 (EDT)
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
Subject: [RFC PATCH v2 14/14] dcache: Implement object migration
Date: Wed,  3 Apr 2019 15:21:27 +1100
Message-Id: <20190403042127.18755-15-tobin@kernel.org>
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

The dentry slab cache is susceptible to internal fragmentation.  Now
that we have Slab Movable Objects we can defragment the dcache.  Object
migration is only possible for dentry objects that are not currently
referenced by anyone, i.e. we are using the object migration
infrastructure to free unused dentries.

Implement isolate and migrate functions for the dentry slab cache.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 87 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 87 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 606844ad5171..4387715b7ebb 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -30,6 +30,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/rculist_bl.h>
 #include <linux/list_lru.h>
+#include <linux/backing-dev.h>
 #include "internal.h"
 #include "mount.h"
 
@@ -3074,6 +3075,90 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+/*
+ * d_isolate() - Dentry isolation callback function.
+ * @s: The dentry cache.
+ * @v: Vector of pointers to the objects to migrate.
+ * @nr: Number of objects in @v.
+ *
+ * The slab allocator is holding off frees. We can safely examine
+ * the object without the danger of it vanishing from under us.
+ */
+static void *d_isolate(struct kmem_cache *s, void **v, int nr)
+{
+	struct dentry *dentry;
+	int i;
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		spin_lock(&dentry->d_lock);
+		/*
+		 * Three sorts of dentries cannot be reclaimed:
+		 *
+		 * 1. dentries that are in the process of being allocated
+		 *    or being freed. In that case the dentry is neither
+		 *    on the LRU nor hashed.
+		 *
+		 * 2. Fake hashed entries as used for anonymous dentries
+		 *    and pipe I/O. The fake hashed entries have d_flags
+		 *    set to indicate a hashed entry. However, the
+		 *    d_hash field indicates that the entry is not hashed.
+		 *
+		 * 3. dentries that have a backing store that is not
+		 *    writable. This is true for tmpsfs and other in
+		 *    memory filesystems. Removing dentries from them
+		 *    would loose dentries for good.
+		 */
+		if ((d_unhashed(dentry) && list_empty(&dentry->d_lru)) ||
+		    (!d_unhashed(dentry) && hlist_bl_unhashed(&dentry->d_hash)) ||
+		    (dentry->d_inode &&
+		     !mapping_cap_writeback_dirty(dentry->d_inode->i_mapping))) {
+			/* Ignore this dentry */
+			v[i] = NULL;
+		} else {
+			__dget_dlock(dentry);
+		}
+		spin_unlock(&dentry->d_lock);
+	}
+	return NULL;		/* No need for private data */
+}
+
+/*
+ * d_migrate() - Dentry migration callback function.
+ * @s: The dentry cache.
+ * @v: Vector of pointers to the objects to migrate.
+ * @nr: Number of objects in @v.
+ * @node: The NUMA node where new object should be allocated.
+ * @private: Returned by d_isolate() (currently %NULL).
+ *
+ * Slab has dropped all the locks. Get rid of the refcount obtained
+ * earlier and also free the object.
+ */
+static void d_migrate(struct kmem_cache *s, void **v, int nr,
+		      int node, void *_unused)
+{
+	struct dentry *dentry;
+	int i;
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		if (dentry)
+			d_invalidate(dentry);
+	}
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		if (dentry)
+			dput(dentry);
+	}
+
+	/*
+	 * dentries are freed using RCU so we need to wait until RCU
+	 * operations are complete.
+	 */
+	synchronize_rcu();
+}
+
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
 {
@@ -3119,6 +3204,8 @@ static void __init dcache_init(void)
 					   sizeof_field(struct dentry, d_iname),
 					   dcache_ctor);
 
+	kmem_cache_setup_mobility(dentry_cache, d_isolate, d_migrate);
+
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
 		return;
-- 
2.21.0

