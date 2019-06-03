Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50AEBC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:29:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0852D27B69
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:29:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="imTMfnlo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0852D27B69
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC0736B0277; Mon,  3 Jun 2019 00:29:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A70866B0278; Mon,  3 Jun 2019 00:29:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95F756B0279; Mon,  3 Jun 2019 00:29:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 766F76B0277
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:29:10 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n77so13708989qke.17
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:29:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xAUe/GSEE+822SPVzryZpZO8XwI9dFOU44eaj5D2zRU=;
        b=uFSYX8PIkBWs1Pwg6uRLB/91VWbJvC9QqqSOQQih+/bx5VvG9a9Nwm14r2+FepA84v
         leTFLbPRgbykO3Hl9hJdamtyqJ9I4sSvlxLxUGitiBxu9oi/+RevcThYAlMjGJZLpHA7
         t9Yyo/KkWgCWqRFh+Pn8EGmcesT0CwbL2wwMrspnxBMMEi23ppxOL4iLmGvNCXJ+X0v3
         0wYlap6qwURrbyGq+tNYymlTvjKg0ci/RcQBqDPZT40f86M0vJWxhoRcoGK4PwniI0Zd
         Ucrn2DSIicBw8DVXmzIMBj6z6UyDYl67JUyE8L4QRMIPpoejxIJ+MtStJG7y4pydAELB
         amUw==
X-Gm-Message-State: APjAAAVGaGE7JqIOkr9s3h6hRFdCV1cL4uTsuovhlcsup/V0Bb0y0mhJ
	OFf30QNX0WVYWOx7ZrhEWcgeiSb/yAQkd67ik6lyo45CjwyANM2F2DetC6kPpI5fau16JxhFdKE
	dSMNRnE7wLhMUY90LaAWe3wwXFeJQZnEqpQ0pe09HCvDCemSKpn8mwaYuZUlWAGc=
X-Received: by 2002:ac8:38d5:: with SMTP id g21mr20836485qtc.52.1559536150227;
        Sun, 02 Jun 2019 21:29:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1hlKAKt3AJTKpd+R42+UNQmMRI0DEmaaEqCBEEXvSARuEWeMyx/rabRcVksLOnpEM1ez4
X-Received: by 2002:ac8:38d5:: with SMTP id g21mr20836453qtc.52.1559536149452;
        Sun, 02 Jun 2019 21:29:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536149; cv=none;
        d=google.com; s=arc-20160816;
        b=H32xkgGbashYABRkCN3NlruEF/OQiVCz0oIeVecCPxonmNVO3uilOJvTyZQG6Khw4G
         sp7y3jSjEF76Xks9PuY1YMOPQrbCrfeUYuHiCYlXFlEHe20UM6TapUICaWimDPhh3Y40
         GzQ97LJf/UvEjLs3x3U/02QC71TBCBs5wPRbLiq+roS9lBfdR8nj5l1tgx2ubpiw661F
         lcxLv/cIGlciK3BF8Z6zbyCDdusbmOk1Ns4YeNc8+5kaDzK+U2/YVHV0xAS9zAeBxGm/
         Z+jGu7glI9xi2Y9H8fTIH1P2/SlzGfF4PdJZ1RtCUt0IyL4YL51FZ7CjrHivSkOxrlzI
         v/MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xAUe/GSEE+822SPVzryZpZO8XwI9dFOU44eaj5D2zRU=;
        b=yGRiaOhNnErpEJo3NYtlAvduXguHLXuKOee0sXmaoXYoXHDj/ADqMnS5AuNH5jKzn3
         VVo0VvphVn5Ih9pHT9A3+GuzfiyCALyqR6SlXfe9hn0zP7NWbtxkBonoeeaW6a2t27Wr
         Ka/R0JBC3wv8VYGemtaB1sBlITC3Oy5FUCV3aM1asmSlyX1GIFPqZRXaeInpcJMcL9KB
         80j+aye2Gn4gXd4gnyaF0YhnFBgwxNAWsuCHJxT5rI5R9YjHsD8YpiV57840DPfEzhYG
         icpokxNNu1OBUnjN6YAIIUgPl7a7QltLbHxSdlMgw71TKkRtMz31yqvIAqxznx/S3MEu
         c2Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=imTMfnlo;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id j7si2414563qth.112.2019.06.02.21.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:29:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=imTMfnlo;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 3641A21A9;
	Mon,  3 Jun 2019 00:29:09 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:29:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=xAUe/GSEE+822SPVzryZpZO8XwI9dFOU44eaj5D2zRU=; b=imTMfnlo
	DxJpQ3ZxqMsQ2FeM4DiG4WgLXKr5msfS1/U/H5OrxPpDNaXEwnxHt8wwMp8oC7L7
	qSZAJSfFctSrnVTckBMZGqjeXdCrcd1oHGlX9em+unJm5R3wii3FXU3s6j/SO/s1
	JbnEVn2Z4DyDP2bkXpiBaXBH1zzCfH0QBVQy4kVden0T4LwoZH2AuV7FosgiURg7
	vsNs0fJPAwfCl4AEl9frWtjJrqBIglSha7eFWUfteIrLpTorvhhugU8jANxdOovL
	GK8/mzteXjES6m4AM50S/0nZUhcdjo1fiIc3EVKknK5JJmkbOV5YZDa878SXgF4W
	0AWGw9QQxSU24A==
X-ME-Sender: <xms:FKL0XL0WBKpXoRtUtKwz4OoxhFG7BliILJQHKZfXbg010fA1-_19wg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:FaL0XFebpgoB0thHOIJmFRPSUuBVzfemRAqNezm-3JVOH5ltVVYuxA>
    <xmx:FaL0XFRUZQt1FCxWTY7IJuij0m5r5sugIYt81uAFWjtVf6wrHAwIuQ>
    <xmx:FaL0XImnw-ykTV2vbadnKyx0B5vvj12XjU7eKKa5InkzQvHTigFhWQ>
    <xmx:FaL0XO69olUJ2D5MOUtv6Pnj7TpteWMBSVsK4ZPKLM8oSDI8hmMPNQ>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id 1FD568005C;
	Mon,  3 Jun 2019 00:29:01 -0400 (EDT)
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
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/15] dcache: Implement partial shrink via Slab Movable Objects
Date: Mon,  3 Jun 2019 14:26:35 +1000
Message-Id: <20190603042637.2018-14-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603042637.2018-1-tobin@kernel.org>
References: <20190603042637.2018-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The dentry slab cache is susceptible to internal fragmentation.  Now
that we have Slab Movable Objects we can attempt to defragment the
dcache.  Dentry objects are inherently _not_ relocatable however under
some conditions they can be free'd.  This is the same as shrinking the
dcache but instead of shrinking the whole cache we only attempt to free
those objects that are located in partially full slab pages.  There is
no guarantee that this will reduce the memory usage of the system, it is
a compromise between fragmented memory and total cache shrinkage with
the hope that some memory pressure can be alleviated.

This is implemented using the newly added Slab Movable Objects
infrastructure.  The dcache 'migration' function is intentionally _not_
called 'd_migrate' because we only free, we do not migrate.  Call it
'd_partial_shrink' to make explicit that no reallocation is done.

In order to enable SMO a call to kmem_cache_setup_mobility() must be
made, we do this during initialization of the dcache.

Implement isolate and 'migrate' functions for the dentry slab cache.
Enable SMO for the dcache during initialization.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 867d97a86940..3ca721752723 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3072,6 +3072,79 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+/*
+ * d_isolate() - Dentry isolation callback function.
+ * @s: The dentry cache.
+ * @v: Vector of pointers to the objects to isolate.
+ * @nr: Number of objects in @v.
+ *
+ * The slab allocator is holding off frees. We can safely examine
+ * the object without the danger of it vanishing from under us.
+ */
+static void *d_isolate(struct kmem_cache *s, void **v, int nr)
+{
+	struct list_head *dispose;
+	struct dentry *dentry;
+	int i;
+
+	dispose = kmalloc(sizeof(*dispose), GFP_KERNEL);
+	if (!dispose)
+		return NULL;
+
+	INIT_LIST_HEAD(dispose);
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		spin_lock(&dentry->d_lock);
+
+		if (dentry->d_lockref.count > 0 ||
+		    dentry->d_flags & DCACHE_SHRINK_LIST) {
+			spin_unlock(&dentry->d_lock);
+			continue;
+		}
+
+		if (dentry->d_flags & DCACHE_LRU_LIST)
+			d_lru_del(dentry);
+
+		d_shrink_add(dentry, dispose);
+		spin_unlock(&dentry->d_lock);
+	}
+
+	return dispose;
+}
+
+/*
+ * d_partial_shrink() - Dentry migration callback function.
+ * @s: The dentry cache.
+ * @_unused: We do not access the vector.
+ * @__unused: No need for length of vector.
+ * @___unused: We do not do any allocation.
+ * @private: list_head pointer representing the shrink list.
+ *
+ * Dispose of the shrink list created during isolation function.
+ *
+ * Dentry objects can _not_ be relocated and shrinking the whole dcache
+ * can be expensive.  This is an effort to free dentry objects that are
+ * stopping slab pages from being free'd without clearing the whole dcache.
+ *
+ * This callback is called from the SLUB allocator object migration
+ * infrastructure in attempt to free up slab pages by freeing dentry
+ * objects from partially full slabs.
+ */
+static void d_partial_shrink(struct kmem_cache *s, void **_unused, int __unused,
+			     int ___unused, void *private)
+{
+	struct list_head *dispose = private;
+
+	if (!private)		/* kmalloc error during isolate. */
+		return;
+
+	if (!list_empty(dispose))
+		shrink_dentry_list(dispose);
+
+	kfree(private);
+}
+
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
 {
@@ -3117,6 +3190,8 @@ static void __init dcache_init(void)
 					   sizeof_field(struct dentry, d_iname),
 					   dcache_ctor);
 
+	kmem_cache_setup_mobility(dentry_cache, d_isolate, d_partial_shrink);
+
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
 		return;
-- 
2.21.0

