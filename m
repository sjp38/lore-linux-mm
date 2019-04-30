Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99DAFC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40B3D21655
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XTK+XwH0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40B3D21655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA66A6B0269; Mon, 29 Apr 2019 23:10:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E55EE6B027C; Mon, 29 Apr 2019 23:10:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E9F6B027D; Mon, 29 Apr 2019 23:10:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B106F6B0269
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:10:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n1so12115938qte.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:10:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K23AG6kPeiLizgBxJZXoFVpxoNhX/Z2JwBtP24yd/wE=;
        b=VuD415CRnkHNDiY3468gW5h1W5mvBZlGhijm1uvXElFU+7pdge6s2EOqGpWoeggWKN
         B8xbSONZTzoDghluVHeVj7w+D4ZVyjEGdHsBc9LtLirAAKII99gR1Kxd2wrdOX1/KAen
         irqD5PDN5hkWvFt7z9UVgFQMsZLfbVgJWsGx6CnHtHsEB4WtiOAqEFii2zQReOen9gFn
         9WvJL0etHe7v1TPmKfQx2KYo6tRNkSY3MACkLMfdiyi1T7bSmZGxyZI0H9DhEkBAfYZ/
         OGujnzhk9B9KLIft9h02qDoirnwnS90pLX2fX1eGxj99qPkcYiAR35oPSB6msoSF4bIz
         HxSw==
X-Gm-Message-State: APjAAAXJDLdCgJf+yaPPZncNuH8LssXif8OEkf5GsRQq+EcQeteuuxtH
	zoOKm21ixIu14MIgKIwSTfdZH0KScWfiEhuM+yJzrVEBUF90KCi42he42m/UZXzlAGowDzVokwy
	RAzCvQoHyUhI4Y4cMihkqvT5a2DRSyDxcUv722SjuJBkb8eyJYupcqAoV0Oqss7o=
X-Received: by 2002:a0c:b29b:: with SMTP id r27mr44992272qve.241.1556593804451;
        Mon, 29 Apr 2019 20:10:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeQQK2w2TtYDL8iq/YsOTkjkLJTGUwOGbqHoIAXVoFt1YUb0jrdCuoiYefpvG/tCcvWdq4
X-Received: by 2002:a0c:b29b:: with SMTP id r27mr44992193qve.241.1556593802963;
        Mon, 29 Apr 2019 20:10:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593802; cv=none;
        d=google.com; s=arc-20160816;
        b=w56TgSOb5msHaNTuviLhxOcYnbusRhWmjmwzyjpz/2wZhvPS4afucVAuqwahLnp8Yh
         jUeIVhoT+RDtVWy8OS8XKoz6K5XD19x0nAdFimwq7zXoX6FxVesH2avkMADBQxRG4MB+
         Prqw1/qtNHN0fAiTqSmDDTvKkESTyAOIZ0dihwwziT9f9Rs1i2OGcISy5kjmpaVGURSU
         Dr9Z/3b1VPiPqKKhv8ajNYxXgnWUY6To6EzXLX776p3lt5HWbZyBM8bW8iMV9NnXrzui
         TWx5WbvfdibkXUwnOYp8+KYFJSMizh5A/vaT05G1LcKK5CLzeufkLL5Z5pfCRxFHm6jj
         +0Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=K23AG6kPeiLizgBxJZXoFVpxoNhX/Z2JwBtP24yd/wE=;
        b=cjeX67yrsv1XnKbA730AhdGkpULpFqra3Im7CYcpXNV8eSyfhF6JEKro9EeEFuKFHa
         xuWPp/OUlBSN+tmSSBYEQX2WHBdnwWWkfosRbyxggbDDGzTlK5eGbvtmmTMEMlhmAKy9
         M/V/2Ufd0udGNZGA0z4IVeMRftddk2wRoPRYJn2j6u+wyE7D0/ODDQBrE2lAZXpaNtCI
         9cn5vRmraAgkKlC9j4jOJLmISi4NrTa6F5MkLTEuZvxcG3zu+8rdiZ8GOWmBWTOYIgy6
         jTIpMBkWEcqFoRT6I7dPYLlDug4EAgE10FYHrpEiexTbU8ZXYw1TV0artRbB2zwRduCr
         u5bA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=XTK+XwH0;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id h51si2640383qth.340.2019.04.29.20.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:10:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=XTK+XwH0;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 9B88C5286;
	Mon, 29 Apr 2019 23:10:02 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:10:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=K23AG6kPeiLizgBxJZXoFVpxoNhX/Z2JwBtP24yd/wE=; b=XTK+XwH0
	oxEqp6vnwjK6+caFT9VVtKjWU9dPddmaa+FjY/fKul/+C3ozeHUt+PTz67oo+YFp
	dO0KXmSWxeH3Gn8ZMuihSs0FzKtgc6OtxwHW9tDjfIKWzMe/5zlF7CCi3JlUZ8/m
	cmmzjPi7BSdf1RWoEv8Ve8GpBdWt1muMdyO7n3chIMm53Hc2iYNQuNQ+0Jnoi1y9
	i1dH8Th5Qsben43b0KwnrQPDdx0xf7yLDBzCR+a3TRr14wuIFdeZsvf0qd6kjpoj
	uiV7WNISxy6CEB2sd8DIprq5su2zF0tt/fO4oKTdPhYDv3NUZDR1crmcUinqQ89Q
	2MqixREsWub7Fw==
X-ME-Sender: <xms:irzHXBPhPfKrMcICVoovHj7hss-ssv2_9XyGSXUaNQ-_fQuh7J853Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeel
X-ME-Proxy: <xmx:irzHXLM0i3vChnzYDmtFh1lKiw3raupoc0zGjEDu_MYCGnFRK_HM_g>
    <xmx:irzHXLKJIqs9UTeKiUC1AwtJoL-469eyoDB_A9CJcObNUv1kQG22WA>
    <xmx:irzHXNoU7VBS95yspSptREa2oBAlj8FUcxRQ8rc2uk0_o-mHwZItXg>
    <xmx:irzHXA67ipTeiSI4gpzwiHL9kWwyhF9nBUjArYJDluNCIggqyCviLA>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6213F103CB;
	Mon, 29 Apr 2019 23:09:54 -0400 (EDT)
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
Subject: [RFC PATCH v4 10/15] tools/testing/slab: Add XArray movable objects tests
Date: Tue, 30 Apr 2019 13:07:41 +1000
Message-Id: <20190430030746.26102-11-tobin@kernel.org>
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

We just implemented movable objects for the XArray.  Let's test it
intree.

Add test module for the XArray's movable objects implementation.

Functionality of the XArray Slab Movable Object implementation can
usually be seen by simply by using `slabinfo` on a running machine since
the radix tree is typically in use on a running machine and will have
partial slabs.  For repeated testing we can use the test module to run
to simulate a workload on the XArray then use `slabinfo` to test object
migration is functioning.

If testing on freshly spun up VM (low radix tree workload) it may be
necessary to load/unload the module a number of times to create partial
slabs.

Example test session
--------------------

Relevant /proc/slabinfo column headers:

  name   <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>

Prior to testing slabinfo report for radix_tree_node:

  # slabinfo radix_tree_node --report

  Slabcache: radix_tree_node  Aliases:  0 Order :  2 Objects: 8352
  ** Reclaim accounting active
  ** Defragmentation at 30%

  Sizes (bytes)     Slabs              Debug                Memory
  ------------------------------------------------------------------------
  Object :     576  Total  :     497   Sanity Checks : On   Total: 8142848
  SlabObj:     912  Full   :     473   Redzoning     : On   Used : 4810752
  SlabSiz:   16384  Partial:      24   Poisoning     : On   Loss : 3332096
  Loss   :     336  CpuSlab:       0   Tracking      : On   Lalig: 2806272
  Align  :       8  Objects:      17   Tracing       : Off  Lpadd:  437360

Here you can see the kernel was built with Slab Movable Objects enabled
for the XArray (XArray uses the radix tree below the surface).

After inserting the test module (note we have triggered allocation of a
number of radix tree nodes increasing the object count but decreasing the
number of partial slabs):

  # slabinfo radix_tree_node --report

  Slabcache: radix_tree_node  Aliases:  0 Order :  2 Objects: 8442
  ** Reclaim accounting active
  ** Defragmentation at 30%

  Sizes (bytes)     Slabs              Debug                Memory
  ------------------------------------------------------------------------
  Object :     576  Total  :     499   Sanity Checks : On   Total: 8175616
  SlabObj:     912  Full   :     484   Redzoning     : On   Used : 4862592
  SlabSiz:   16384  Partial:      15   Poisoning     : On   Loss : 3313024
  Loss   :     336  CpuSlab:       0   Tracking      : On   Lalig: 2836512
  Align  :       8  Objects:      17   Tracing       : Off  Lpadd:  439120

Now we can shrink the radix_tree_node cache:

  # slabinfo radix_tree_node --shrink
  # slabinfo radix_tree_node --report

  Slabcache: radix_tree_node  Aliases:  0 Order :  2 Objects: 8515
  ** Reclaim accounting active
  ** Defragmentation at 30%

  Sizes (bytes)     Slabs              Debug                Memory
  ------------------------------------------------------------------------
  Object :     576  Total  :     501   Sanity Checks : On   Total: 8208384
  SlabObj:     912  Full   :     500   Redzoning     : On   Used : 4904640
  SlabSiz:   16384  Partial:       1   Poisoning     : On   Loss : 3303744
  Loss   :     336  CpuSlab:       0   Tracking      : On   Lalig: 2861040
  Align  :       8  Objects:      17   Tracing       : Off  Lpadd:  440880

Note the single remaining partial slab.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/testing/slab/Makefile             |   2 +-
 tools/testing/slab/slub_defrag_xarray.c | 211 ++++++++++++++++++++++++
 2 files changed, 212 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/slab/slub_defrag_xarray.c

diff --git a/tools/testing/slab/Makefile b/tools/testing/slab/Makefile
index 440c2e3e356f..44c18d9a4d52 100644
--- a/tools/testing/slab/Makefile
+++ b/tools/testing/slab/Makefile
@@ -1,4 +1,4 @@
-obj-m += slub_defrag.o
+obj-m += slub_defrag.o slub_defrag_xarray.o
 
 KTREE=../../..
 
diff --git a/tools/testing/slab/slub_defrag_xarray.c b/tools/testing/slab/slub_defrag_xarray.c
new file mode 100644
index 000000000000..41143f73256c
--- /dev/null
+++ b/tools/testing/slab/slub_defrag_xarray.c
@@ -0,0 +1,211 @@
+// SPDX-License-Identifier: GPL-2.0+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/uaccess.h>
+#include <linux/list.h>
+#include <linux/gfp.h>
+#include <linux/xarray.h>
+
+#define SMOX_CACHE_NAME "smox_test"
+static struct kmem_cache *cachep;
+
+/*
+ * Declare XArrays globally so we can clean them up on module unload.
+ */
+
+/* Used by test_smo_xarray()*/
+DEFINE_XARRAY(things);
+
+/* Thing to store pointers to in the XArray */
+struct smox_thing {
+	long id;
+};
+
+/* It's up to the caller to ensure id is unique */
+static struct smox_thing *alloc_thing(int id)
+{
+	struct smox_thing *thing;
+
+	thing = kmem_cache_alloc(cachep, GFP_KERNEL);
+	if (!thing)
+		return ERR_PTR(-ENOMEM);
+
+	thing->id = id;
+	return thing;
+}
+
+/**
+ * smox_object_ctor() - SMO object constructor function.
+ * @ptr: Pointer to memory where the object should be constructed.
+ */
+void smox_object_ctor(void *ptr)
+{
+	struct smox_thing *thing = ptr;
+
+	thing->id = -1;
+}
+
+/**
+ * smox_cache_migrate() - kmem_cache migrate function.
+ * @cp: kmem_cache pointer.
+ * @objs: Array of pointers to objects to migrate.
+ * @size: Number of objects in @objs.
+ * @node: NUMA node where the object should be allocated.
+ * @private: Pointer returned by kmem_cache_isolate_func().
+ */
+void smox_cache_migrate(struct kmem_cache *cp, void **objs, int size,
+			int node, void *private)
+{
+	struct smox_thing **ptrs = (struct smox_thing **)objs;
+	struct smox_thing *old, *new;
+	struct smox_thing *thing;
+	unsigned long index;
+	void *entry;
+	int i;
+
+	for (i = 0; i < size; i++) {
+		old = ptrs[i];
+
+		new = kmem_cache_alloc(cachep, GFP_KERNEL);
+		if (!new) {
+			pr_debug("kmem_cache_alloc failed\n");
+			return;
+		}
+
+		new->id = old->id;
+
+		/* Update reference the brain dead way */
+		xa_for_each(&things, index, thing) {
+			if (thing == old) {
+				entry = xa_store(&things, index, new, GFP_KERNEL);
+				if (entry != old) {
+					pr_err("failed to exchange new/old\n");
+					return;
+				}
+			}
+		}
+		kmem_cache_free(cachep, old);
+	}
+}
+
+/*
+ * test_smo_xarray() - Run some tests using an XArray.
+ */
+static int test_smo_xarray(void)
+{
+	const int keep = 6; /* Free 5 out of 6 items */
+	const int nr_items = 10000;
+	struct smox_thing *thing;
+	unsigned long index;
+	void *entry;
+	int expected;
+	int i;
+
+	/*
+	 * Populate XArray, this adds to the radix_tree_node cache as
+	 * well as the smox_test cache.
+	 */
+	for (i = 0; i < nr_items; i++) {
+		thing = alloc_thing(i);
+		entry = xa_store(&things, i, thing, GFP_KERNEL);
+		if (xa_is_err(entry)) {
+			pr_err("smox: failed to allocate entry: %d\n", i);
+			return -ENOMEM;
+		}
+	}
+
+	/* Now free  items, putting holes in both caches. */
+	for (i = 0; i < nr_items; i++) {
+		if (i % keep == 0)
+			continue;
+
+		thing = xa_erase(&things, i);
+		if (xa_is_err(thing))
+			pr_err("smox: error erasing entry: %d\n", i);
+		kmem_cache_free(cachep, thing);
+	}
+
+	expected = 0;
+	xa_for_each(&things, index, thing) {
+		if (thing->id != expected || index != expected) {
+			pr_err("smox: error; got %ld want %d at %ld\n",
+			       thing->id, expected, index);
+			return -1;
+		}
+		expected += keep;
+	}
+
+	/*
+	 * Leave caches sparsely allocated.  Shrink caches manually with:
+	 *
+	 *   slabinfo radix_tree_node --shrink
+	 *   slabinfo smox_test --shrink
+	 */
+
+	return 0;
+}
+
+static int __init smox_cache_init(void)
+{
+	cachep = kmem_cache_create(SMOX_CACHE_NAME,
+				   sizeof(struct smox_thing),
+				   0, 0, smox_object_ctor);
+	if (!cachep)
+		return -1;
+
+	return 0;
+}
+
+static void __exit smox_cache_cleanup(void)
+{
+	struct smox_thing *thing;
+	unsigned long i;
+
+	xa_for_each(&things, i, thing) {
+		kmem_cache_free(cachep, thing);
+	}
+	xa_destroy(&things);
+	kmem_cache_destroy(cachep);
+}
+
+static int __init smox_init(void)
+{
+	int ret;
+
+	ret = smox_cache_init();
+	if (ret) {
+		pr_err("smo_xarray: failed to create cache\n");
+		return ret;
+	}
+	pr_info("smo_xarray: created kmem_cache: %s\n", SMOX_CACHE_NAME);
+
+	kmem_cache_setup_mobility(cachep, NULL, smox_cache_migrate);
+	pr_info("smo_xarray: kmem_cache %s defrag enabled\n", SMOX_CACHE_NAME);
+
+	/*
+	 * Running this test consumes memory unless you shrink the
+	 * radix_tree_node cache manually with `slabinfo`.
+	 */
+	ret = test_smo_xarray();
+	if (ret)
+		pr_warn("test_smo_xarray failed: %d\n", ret);
+
+	pr_info("smo_xarray: module loaded successfully\n");
+	return 0;
+}
+module_init(smox_init);
+
+static void __exit smox_exit(void)
+{
+	smox_cache_cleanup();
+
+	pr_info("smo_xarray: module removed\n");
+}
+module_exit(smox_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Tobin C. Harding");
+MODULE_DESCRIPTION("SMO XArray test module.");
-- 
2.21.0

